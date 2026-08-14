;;; elauncher --- 

;; Copyright (C) 2026  

;; Author: Yusuke KUDO <ajsmithy00@gmail.com>
;; Keywords: tools
;; URL: https://github.com/hodumi/elauncher
;; Version: 0.1

;;; Commentary:

;; EmacsからWindows上のプログラムを起動する関数を定義するパッケージです。
;; 定義した関数は、M-xやキーバインドから呼び出せます。
;;
;; (elauncher:defapplication 関数名 プログラムパス パラメータ)
;;  プログラムパスのプログラムを起動します。

;; (elauncher:defexplorer 関数名 フォルダパス)
;;  エクスプローラでフォルダパスを開きます。

;; Examples.
;;(elauncher:defexplorer elauncher:open-default-directory default-directory) ; default-directoryの表示
;;(elauncher:defexplorer elauncher:open-home-directory "~" ) ; HOMEの表示
;;(elauncher:defapplication run-calc "calc") ; calc.exeの起動

;;; Code:

;;;###autoload
(defun elauncher:open-directory (&optional directory)
  "Open DIRECTORY (or `default-directory') in Windows Explorer."
  (when (eq system-type 'windows-nt)
    (let ((dir (or directory default-directory)))
      (message "Opened: %s" dir)
      (w32-shell-execute "explore" dir))))

;;;###autoload
(defun elauncher:run-application (file &optional parameters)
  "Run FILE with optional PARAMETERS on Windows."
  (when (eq system-type 'windows-nt)
    (message "Opened: %s %s" file parameters)
    (w32-shell-execute "open" file parameters)))

;;;###autoload
(defmacro elauncher:defexplorer (name directory)
  "Define a NAME function that opens DIRECTORY with Explorer."
  `(defun ,name ()
     (interactive)
     (elauncher:open-directory ,directory)))

;;;###autoload
(defmacro elauncher:defapplication (name file &optional parameters)
  "Define a NAME function that launches FILE with optional PARAMETERS."
  `(defun ,name ()
     (interactive)
     (elauncher:run-application ,file ,parameters)))

;;;###autoload
(elauncher:defexplorer elauncher:open-default-directory default-directory) ; default-directoryの表示

(provide 'elauncher)
;;; elauncher ends here
