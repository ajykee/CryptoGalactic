;; CryptoGalactic - Space NFT Marketplace
;; A comprehensive NFT marketplace for space-themed digital assets

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-token-exists (err u102))
(define-constant err-not-listed (err u103))
(define-constant err-already-listed (err u104))
(define-constant err-wrong-price (err u105))
(define-constant err-insufficient-funds (err u106))
(define-constant err-transfer-failed (err u107))

;; NFT Data Variables
(define-non-fungible-token space-nft uint)
(define-data-var last-token-id uint u0)
(define-map token-uris uint (string-ascii 256))
(define-map token-metadata uint {
    name: (string-ascii 64),
    description: (string-ascii 256),
    rarity: (string-ascii 32),
    category: (string-ascii 32),
    creation-date: uint
})

;; Marketplace Data Variables
(define-map listings uint {
    owner: principal,
    price: uint,
    listed-at: uint
})
(define-data-var marketplace-fee uint u25) ;; 2.5% fee
(define-map sales uint {
    seller: principal,
    buyer: principal,
    price: uint,
    timestamp: uint
})

;; Private Functions - NFT Operations
(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? space-nft token-id) false))
)

(define-private (mint-token (token-id uint) (recipient principal))
    (begin
        (try! (nft-mint? space-nft token-id recipient))
        (ok true)
    )
)

;; Private Functions - Marketplace Operations
(define-private (transfer-stx (amount uint) (sender principal) (recipient principal))
    (if (is-eq sender (as-contract tx-sender))
        (as-contract (stx-transfer? amount sender recipient))
        (stx-transfer? amount sender recipient)
    )
)

(define-private (calculate-fee (price uint))
    (/ (* price (var-get marketplace-fee)) u1000)
)

(define-private (record-sale (token-id uint) (seller principal) (buyer principal) (price uint))
    (map-set sales token-id {
        seller: seller,
        buyer: buyer,
        price: price,
        timestamp: block-height
    })
)

;; Public Functions - NFT Operations
(define-public (mint (recipient principal) 
                    (name (string-ascii 64)) 
                    (description (string-ascii 256))
                    (token-uri (string-ascii 256))
                    (rarity (string-ascii 32))
                    (category (string-ascii 32)))
    (let ((token-id (+ (var-get last-token-id) u1)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (try! (mint-token token-id recipient))
        (map-set token-uris token-id token-uri)
        (map-set token-metadata token-id {
            name: name,
            description: description,
            rarity: rarity,
            category: category,
            creation-date: block-height
        })
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-owner token-id sender) err-not-token-owner)
        (asserts! (is-none (map-get? listings token-id)) err-already-listed)
        (try! (nft-transfer? space-nft token-id sender recipient))
        (ok true)
    )
)

;; Public Functions - Marketplace Operations
(define-public (list-asset (token-id uint) (price uint))
    (let ((token-owner (unwrap! (nft-get-owner? space-nft token-id) err-not-token-owner)))
        (asserts! (is-eq tx-sender token-owner) err-not-token-owner)
        (asserts! (is-none (map-get? listings token-id)) err-already-listed)
        (map-set listings token-id {
            owner: tx-sender,
            price: price,
            listed-at: block-height
        })
        (ok true)
    )
)

(define-public (unlist-asset (token-id uint))
    (let ((listing (unwrap! (map-get? listings token-id) err-not-listed)))
        (asserts! (is-eq tx-sender (get owner listing)) err-not-token-owner)
        (map-delete listings token-id)
        (ok true)
    )
)

(define-public (purchase-asset (token-id uint))
    (let
        (
            (listing (unwrap! (map-get? listings token-id) err-not-listed))
            (price (get price listing))
            (seller (get owner listing))
            (fee (calculate-fee price))
            (seller-amount (- price fee))
        )
        (asserts! (not (is-eq tx-sender seller)) err-owner-only)
        (try! (transfer-stx price tx-sender seller))
        (try! (transfer-stx fee tx-sender contract-owner))
        (try! (nft-transfer? space-nft token-id seller tx-sender))
        (map-delete listings token-id)
        (record-sale token-id seller tx-sender price)
        (ok true)
    )
)

;; Read-only Functions - NFT Queries
(define-read-only (get-token-uri (token-id uint))
    (ok (map-get? token-uris token-id))
)

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? space-nft token-id))
)

(define-read-only (get-metadata (token-id uint))
    (ok (map-get? token-metadata token-id))
)

(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

;; Read-only Functions - Marketplace Queries
(define-read-only (get-listing (token-id uint))
    (ok (map-get? listings token-id))
)

(define-read-only (get-marketplace-fee)
    (ok (var-get marketplace-fee))
)

(define-read-only (get-sale-history (token-id uint))
    (ok (map-get? sales token-id))
)

;; Admin Functions
(define-public (set-marketplace-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (<= new-fee u100) err-wrong-price)
        (var-set marketplace-fee new-fee)
        (ok true)
    )
)