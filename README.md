# CryptoGalactic Smart Contract

A comprehensive NFT marketplace smart contract for space-themed digital assets, built with Clarity.

## Features

### NFT Functionality
- Mint unique space-themed NFTs with metadata
- Transfer NFTs between users
- Store detailed metadata including name, description, rarity, and category
- Track creation dates and ownership history

### Marketplace Operations
- List NFTs for sale with custom pricing
- Unlist NFTs from the marketplace
- Purchase NFTs with automatic fee handling
- 2.5% marketplace fee (configurable by owner)
- Complete sale history tracking

### Security Features
- Owner-only administrative functions
- Protected transfer mechanisms
- Secure payment processing
- Comprehensive error handling
- Input validation

### Query Functions
- Get token metadata and ownership information
- View current listings and prices
- Access sale history
- Check marketplace fees

## Technical Details

The contract combines NFT and marketplace functionality in a single, efficient implementation:

- Non-fungible token implementation
- Marketplace listings management
- Automated fee calculation and distribution
- Comprehensive metadata storage
- Transaction history tracking
- Administrative controls

## Security Considerations

- Owner verification for sensitive operations
- Protected transfer mechanisms
- Payment validation
- Listed asset protection
- Fee validation

## Error Codes

- u100: Owner only operation
- u101: Not token owner
- u102: Token already exists
- u103: Asset not listed
- u104: Asset already listed
- u105: Invalid price
- u106: Insufficient funds
- u107: Transfer failed