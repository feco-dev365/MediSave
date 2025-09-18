# MediSave

A decentralized health emergency wallet system built on the Stacks blockchain that allows users to save funds for medical emergencies while ensuring secure, validated access through authorized healthcare providers.

## 🌟 Overview

MediSave is a revolutionary blockchain-based solution that addresses the critical need for accessible emergency healthcare funding. By leveraging smart contracts, we create a secure, transparent, and efficient system where users can save for medical emergencies while ensuring funds are only accessible during validated health crises.

## 🔧 Key Functional Features

### ✅ Smart Emergency Wallets (Current Implementation)
- **Secure Savings**: Users can deposit small amounts into locked emergency wallets
- **Emergency Validation**: Funds can only be accessed when emergencies are validated by authorized healthcare providers
- **Transparent Operations**: All transactions are recorded on the blockchain for full transparency

### 🚧 Planned Features (Future Development)
- **Verified Healthcare Provider Access**: Whitelist system for hospitals and medical facilities
- **Guardian Consent Layer**: Multi-signature approval from next-of-kin or guardians
- **Donation Matching Pool**: NGO and DAO matching for verified emergency cases
- **Advanced Emergency Unlock Conditions**: Geo-location, medical codes, and guardian signatures
- **Privacy Features**: Zero-knowledge proofs for health detail protection
- **Comprehensive Audit System**: Enhanced transparency and verification tools

## 🏗️ Technical Architecture

### Smart Contract Structure
- **Language**: Clarity (Stacks blockchain)
- **Framework**: Clarinet for development and testing
- **Security**: Multi-layered validation and authorization system

### Core Components
1. **Emergency Wallets**: Individual user savings accounts with locked access
2. **Provider Authorization**: System for validating healthcare providers
3. **Emergency Validation**: Secure process for unlocking funds during emergencies
4. **Fund Release**: Automated payout system to authorized providers

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- [Stacks CLI](https://docs.stacks.co/docs/write-smart-contracts/cli-wallet-quickstart) for wallet management
- Node.js (for testing and development tools)

### Installation

1. **Clone the repository**
   \`\`\`bash
   git clone https://github.com/your-org/medisave-emergency-wallet.git
   cd medisave-emergency-wallet
   \`\`\`

2. **Install Clarinet** (if not already installed)
   \`\`\`bash
   # macOS
   brew install clarinet
   
   # Or download from GitHub releases
   # https://github.com/hirosystems/clarinet/releases
   \`\`\`

3. **Initialize the project**
   \`\`\`bash
   clarinet check
   \`\`\`

### Development

#### Running Tests
\`\`\`bash
# Check contract syntax
clarinet check

# Run all tests
clarinet test

# Start local development environment
clarinet integrate
\`\`\`

#### Contract Deployment
\`\`\`bash
# Deploy to testnet
clarinet deploy --testnet

# Deploy to mainnet (production)
clarinet deploy --mainnet
\`\`\`

## 📋 Usage Guide

### For Users

#### 1. Create Emergency Wallet
```clarity
;; Create a new emergency wallet
(contract-call? .emergency-wallet create-emergency-wallet)
