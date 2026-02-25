;; ============================================================
;; Contract: sybil-shield.clar
;; Purpose : Composable on-chain Sybil-resistance module
;; ============================================================

;; -------------------------
;; ERRORS
;; -------------------------
(define-constant ERR-NOT-OWNER          (err u19001))
(define-constant ERR-ALREADY-REGISTERED (err u19002))
(define-constant ERR-INVALID-PROOF      (err u19003))
(define-constant ERR-NOT-VERIFIED       (err u19004))

;; -------------------------
;; STORAGE
;; -------------------------

;; Contract owner
(define-data-var contract-owner principal tx-sender)

;; Authorized identity validators
(define-map validators
  principal
  bool
)

;; user principal => unique id hash
(define-map identities
  principal
  {
    id-hash: (buff 32),
    verified: bool
  }
)

;; -------------------------
;; READ-ONLY HELPERS
;; -------------------------

(define-read-only (is-owner?)
  (is-eq tx-sender (var-get contract-owner))
)

(define-read-only (is-validator? (v principal))
  (default-to false (map-get? validators v))
)

;; -------------------------
;; OWNER CONTROLS
;; -------------------------

(define-public (add-validator (v principal))
  (begin
    (asserts! (is-owner?) ERR-NOT-OWNER)
    (asserts! (not (is-eq v tx-sender)) ERR-INVALID-PROOF)
    (map-set validators v true)
    (ok true)
  )
)

(define-public (remove-validator (v principal))
  (begin
    (asserts! (is-owner?) ERR-NOT-OWNER)
    (asserts! (not (is-eq v tx-sender)) ERR-INVALID-PROOF)
    (map-delete validators v)
    (ok true)
  )
)

;; -------------------------
;; IDENTITY REGISTRATION
;; -------------------------

(define-public (register-identity
  (id-hash (buff 32))
)
  (begin
    (asserts! (> (len id-hash) u0) ERR-INVALID-PROOF)
    (asserts! (is-none (map-get? identities tx-sender)) ERR-ALREADY-REGISTERED)
    (map-set identities tx-sender { id-hash: id-hash, verified: false })
    (ok true)
  )
)

;; -------------------------
;; VALIDATION BY AUTHORIZED VALIDATOR
;; -------------------------

(define-public (verify-identity
  (user principal)
)
  (begin
    (asserts! (is-validator? tx-sender) ERR-NOT-OWNER)

    (let ((identity (map-get? identities user)))
      (asserts! (is-some identity) ERR-NOT-VERIFIED)

      (map-set identities user
        (merge (unwrap! identity ERR-NOT-VERIFIED)
               { verified: true })
      )

      (ok true)
    )
  )
)

;; -------------------------
;; READ INTERFACE
;; -------------------------

(define-read-only (identity-status (user principal))
  (match (map-get? identities user)
    identity (ok identity)
    (err ERR-NOT-VERIFIED)
  )
)

(define-read-only (is-verified? (user principal))
  (match (map-get? identities user)
    identity (get verified identity)
    false
  )
)
