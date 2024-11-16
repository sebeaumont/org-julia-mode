;;; org-julia-mode.el --- Major mode for working with literate Org Julia files
;;; -*- lexical-binding: t

;;; Commentary:

;; A Major mode for editing Julia code embedded in Org files (..org files.)

;;; Code:

(require 'polymode)
(require 'julia-mode)

(defgroup org-julia-mode nil
  "Some org-julia-mode customisations."
  :group 'languages)

(define-hostmode poly-org-julia-hostmode
  :mode 'org-mode
  :keep-in-mode 'host)

(define-innermode poly-org-julia-innermode
  :mode 'julia-mode
  :head-matcher "#\\+begin_src jupyter-julia"
  :tail-matcher "#\\+end_src"
  ;; Keep the code block wrappers in Org mode, so they can be folded, etc.
  :head-mode 'org-mode
  :tail-mode 'org-mode
                             
  ;; Disable font-lock-mode
  ;; and undo the change to indent-line-function Polymode makes.
  :init-functions
  '((lambda (_) (font-lock-mode 0))
    (lambda (_) (setq indent-line-function #'indent-relative))))

(define-polymode org-julia-mode
  :hostmode 'poly-org-julia-hostmode
  :innermodes '(poly-org-julia-innermode)
  (setq-local org-src-fontify-natively t)
  (setq-local polymode-after-switch-buffer-hook
              (append '(after-switch-hook) polymode-after-switch-buffer-hook)))

(defun after-switch-hook (_ new)
  "The after buffer switch hook run with NEW buffer."
  (when (bufferp new)
    (let ((new-mode (buffer-local-value 'major-mode new)))
      ;;(message "switch to: %s" new-mode)
      (cond ((eq new-mode 'julia-mode) (julia-mode-hook new))
            ((eq new-mode 'org-mode) (org-mode-hook new))))))

(defun org-mode-hook (buf)
  "Hook run after entering `org-mode` with BUF."
  (font-lock-update)
  (if (buffer-modified-p buf)
      (message "dirty-org")
    (message "clean-org")))

(defun julia-mode-hook (buf)
  "Hook run after entering `julia-mode` with BUF."
  (font-lock-update)
  (if (buffer-modified-p buf)
      (message "dirty-julia")
    (message "clean-julia")))


;;;###autoload
;; (add-to-list 'auto-mode-alist '("\\.ljulia.org" . org-julia-mode))

(provide 'org-julia-mode)
;;; org-julia-mode.el ends here
