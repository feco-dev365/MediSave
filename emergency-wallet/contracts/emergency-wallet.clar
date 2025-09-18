;; MediSave Emergency Wallet Smart Contract
;; Allows users to save funds that can only be accessed during validated emergencies

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INSUFFICIENT_FUNDS (err u101))
(define-constant ERR_WALLET_NOT_FOUND (err u102))
(define-constant ERR_EMERGENCY_NOT_VALIDATED (err u103))
(define-constant ERR_ALREADY_EXISTS (err u104))
(define-constant ERR_INVALID_AMOUNT (err u105))

;; Data Variables
(define-data-var contract-owner principal CONTRACT_OWNER)

;; Data Maps
;; Emergency wallets for each user
(define-map emergency-wallets 
  { user: principal }
  { 
    balance: uint,
    is-locked: bool,
    created-at: uint,
    last-deposit: uint
  }
)

;; Emergency validation records
(define-map emergency-validations
  { user: principal, emergency-id: uint }
  {
    is-validated: bool,
    validator: principal,
    validated-at: uint,
    emergency-type: (string-ascii 50)
  }
)

;; Authorized healthcare providers
(define-map authorized-providers
  { provider: principal }
  {
    is-authorized: bool,
    name: (string-ascii 100),
    license-number: (string-ascii 50),
    authorized-at: uint
  }
)

;; Emergency counter for unique IDs
(define-data-var emergency-counter uint u0)

;; Public Functions

;; Create a new emergency wallet
(define-public (create-emergency-wallet)
  (let ((user tx-sender))
    (match (map-get? emergency-wallets { user: user })
      existing-wallet ERR_ALREADY_EXISTS
      (begin
        (map-set emergency-wallets 
          { user: user }
          {
            balance: u0,
            is-locked: true,
            created-at: stacks-block-height,
            last-deposit: u0
          }
        )
        (ok true)
      )
    )
  )
)

;; Deposit funds into emergency wallet
(define-public (deposit-to-wallet (amount uint))
  (let (
    (user tx-sender)
    (wallet-data (unwrap! (map-get? emergency-wallets { user: user }) ERR_WALLET_NOT_FOUND))
  )
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (stx-transfer? amount user (as-contract tx-sender)))
    (map-set emergency-wallets
      { user: user }
      {
        balance: (+ (get balance wallet-data) amount),
        is-locked: (get is-locked wallet-data),
        created-at: (get created-at wallet-data),
        last-deposit: stacks-block-height
      }
    )
    (ok amount)
  )
)

;; Validate emergency (only authorized providers)
(define-public (validate-emergency (user principal) (emergency-type (string-ascii 50)))
  (let (
    (provider tx-sender)
    (emergency-id (+ (var-get emergency-counter) u1))
    (provider-data (unwrap! (map-get? authorized-providers { provider: provider }) ERR_UNAUTHORIZED))
  )
    (asserts! (get is-authorized provider-data) ERR_UNAUTHORIZED)
    (var-set emergency-counter emergency-id)
    (map-set emergency-validations
      { user: user, emergency-id: emergency-id }
      {
        is-validated: true,
        validator: provider,
        validated-at: stacks-block-height,
        emergency-type: emergency-type
      }
    )
    (ok emergency-id)
  )
)

;; Release emergency funds (only to authorized providers)
(define-public (release-emergency-funds (user principal) (emergency-id uint) (amount uint))
  (let (
    (provider tx-sender)
    (wallet-data (unwrap! (map-get? emergency-wallets { user: user }) ERR_WALLET_NOT_FOUND))
    (validation-data (unwrap! (map-get? emergency-validations { user: user, emergency-id: emergency-id }) ERR_EMERGENCY_NOT_VALIDATED))
    (provider-data (unwrap! (map-get? authorized-providers { provider: provider }) ERR_UNAUTHORIZED))
  )
    (asserts! (get is-authorized provider-data) ERR_UNAUTHORIZED)
    (asserts! (get is-validated validation-data) ERR_EMERGENCY_NOT_VALIDATED)
    (asserts! (>= (get balance wallet-data) amount) ERR_INSUFFICIENT_FUNDS)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    
    ;; Transfer funds from contract to provider
    (try! (as-contract (stx-transfer? amount tx-sender provider)))
    
    ;; Update wallet balance
    (map-set emergency-wallets
      { user: user }
      {
        balance: (- (get balance wallet-data) amount),
        is-locked: (get is-locked wallet-data),
        created-at: (get created-at wallet-data),
        last-deposit: (get last-deposit wallet-data)
      }
    )
    (ok amount)
  )
)

;; Authorize healthcare provider (only contract owner)
(define-public (authorize-provider (provider principal) (name (string-ascii 100)) (license-number (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (map-set authorized-providers
      { provider: provider }
      {
        is-authorized: true,
        name: name,
        license-number: license-number,
        authorized-at: stacks-block-height
      }
    )
    (ok true)
  )
)

;; Revoke provider authorization (only contract owner)
(define-public (revoke-provider (provider principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (match (map-get? authorized-providers { provider: provider })
      existing-provider 
      (begin
        (map-set authorized-providers
          { provider: provider }
          {
            is-authorized: false,
            name: (get name existing-provider),
            license-number: (get license-number existing-provider),
            authorized-at: (get authorized-at existing-provider)
          }
        )
        (ok true)
      )
      ERR_UNAUTHORIZED
    )
  )
)

;; Read-only functions

;; Get wallet balance
(define-read-only (get-wallet-balance (user principal))
  (match (map-get? emergency-wallets { user: user })
    wallet-data (ok (get balance wallet-data))
    ERR_WALLET_NOT_FOUND
  )
)

;; Get wallet info
(define-read-only (get-wallet-info (user principal))
  (map-get? emergency-wallets { user: user })
)

;; Check if provider is authorized
(define-read-only (is-provider-authorized (provider principal))
  (match (map-get? authorized-providers { provider: provider })
    provider-data (get is-authorized provider-data)
    false
  )
)

;; Get emergency validation status
(define-read-only (get-emergency-validation (user principal) (emergency-id uint))
  (map-get? emergency-validations { user: user, emergency-id: emergency-id })
)

;; Get provider info
(define-read-only (get-provider-info (provider principal))
  (map-get? authorized-providers { provider: provider })
)

;; Get current emergency counter
(define-read-only (get-emergency-counter)
  (var-get emergency-counter)
)
