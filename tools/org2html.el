;; Output and style HTML
;;
;;  Copyright (C) 2014 LoVullo Associates, Inc.
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU General Public License for more details.
;;
;;  You should have received a copy of the GNU General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.

(require 'ox-publish)

(setq org-publish-project-alist
      `(("lv-notes-public"
         :base-directory "."
         :publishing-directory "www-root"
         :recursive t
         :publishing-function org-html-publish-to-html

         :exclude "README.org"

         :auto-sitemap t
         :sitemap-title "Notes Sitemap"

         :headline-levels 1
         :section-numbers t

         :html-html5-fancy t
         :html-link-home "./"
         :html-link-up "../"
         :html-head-include-default-style nil
         :html-head ,(concat
                      "<link rel=\"stylesheet\" "
                      "type=\"text/css\" "
                      "href=\"/style.css\" />")))

      org-html-home/up-format
      (concat
       "<div id=\"org-div-home-and-up\">"
       "<a accesskey=\"h\" href=\"%s\">Up</a> | "
       "<a accesskey=\"H\" href=\"%s\">Home</a>"
       "</div>"))

(org-publish "lv-notes-public")
