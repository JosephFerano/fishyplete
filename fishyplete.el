
(defcustom fishyplete-preview-delay 0.0
  "How long to wait until displaying the preview after a keystroke.

The value is in seconds."
  :type 'float
  :group 'fishyplete)

(defface fishyplete-preview-face
  '((t (:inherit shadow)))
  "Face for the preview.")

;; (setq joe/test-overlay (make-overlay (- (point-max) 5) (point-max)))

(setq text-to-display "12345")
;; (add-text-properties 0 1 '(cursor 1) text-to-display)
(add-text-properties 0 (length text-to-display)
                     '(face fishyplete-preview-face) text-to-display)
;; (overlay-put joe/test-overlay 'face 'fishyplete-preview-face)
(overlay-put joe/test-overlay 'after-string text-to-display)

(delete-overlay joe/test-overlay)
(remove-overlays)

(defun fishyplete--pre-command ()
  (when fishyplete--overlay
    (delete-overlay fishyplete--overlay)
    (setq text-to-display nil)
    (setq fishyplete--overlay nil)))

(defun fishyplete--post-command ()
  (setq fishyplete--overlay (make-overlay (point) (point)))
  (setq text-to-display (elisp-completion-at-point))
  (add-text-properties 0 (length text-to-display)
                       '(face fishyplete-preview-face) text-to-display)
  (overlay-put fishyplete--overlay 'after-string text-to-display))
(elisp-completion-at-point)
(defun joe/test-capf ()
  (interactive)
  (pcase  (elisp-completion-at-point)
    ((and res `(,beg ,end ,table . ,plist))
     (message "%s" table))))
(joe/test-capf)
(define-key global-map (kbd "C-S-i") #'joe/test-capf)

(defun joe/get-completions (string)
  "Get a list of completions for STRING using `completion-at-point-functions'."
  (let ((completion-at-point-functions completion-at-point-functions)
        (completions nil))
    (run-hook-wrapped 'completion-at-point-functions
                      (lambda (f)
                        (message "Did we find completions? %s" (funcall f))
                        (setq completions (funcall f))))
    completions))


(defun joe/show-first-completion (string)
  "Show the first completion for STRING using overlays."
  (let ((completions (joe/get-completions string)))
    (if completions
        (let ((first-completion
               (try-completion string
                               (nth 2 completions)
                               (plist-get (nthcdr 3 completions) :predicate))))
          (message "%s" first-completion))
      (message "No completions found"))))

(joe/show-first-completion "completion-at-poi")

(completion-in-region (point) (point) '(foo bar baz))

(defun fishyplete--post-command () 
  (message "%s" (elisp-completion-at-point)))
(elisp--completion-local-symbols)
(completion-at-point)
(completion-in-region)
(completion-try-completion (- (point) 20) (- (point) 10))
;; (defun joe/test-post-command-hook () (message "Hello I am %s" this-command))
;; (add-hook 'post-command-hook #'joe/test-post-command-hook nil t)
(completion-at-point)
;;;###autoload
(define-minor-mode fishyplete-mode
  :init-value nil
  (if fishyplete-mode
      (progn
        (add-hook 'pre-command-hook #'fishyplete--pre-command nil t)
        (add-hook 'post-command-hook #'fishyplete--post-command nil t))
    (remove-hook 'pre-command-hook #'fishyplete--pre-command t)
    (remove-hook 'post-command-hook #'fishyplete--post-command t)))


;;;###autoload
(define-globalized-minor-mode global-fishyplete-mode
  fishyplete-mode
  (lambda () (fishyplete-mode 1)))

(provide 'fishyplete)
;;; fishyplete.el ends here
