# Notes build
#
#  Copyright (C) 2014 LoVullo Associates, Inc.
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##

org_src=$(wildcard *.org)
org_html=$(patsubst %.org, %.html, $(org_src))

.PHONY: default org-html clean

default: org-html

org-html: $(org_html)
%.html: %.org
	emacs --batch "$<" -l tools/org2html.el > "$@"

clean:
	$(RM) $(org_html)
