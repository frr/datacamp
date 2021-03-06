# Pages Controller
#
# Copyright:: (C) 2009 Knowerce, s.r.o.
# 
# Author:: Vojto Rinik <vojto@rinik.net>
# Date: Sep 2009
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class PagesController < ApplicationController
  def show
    begin
      @page = Page.find_by_page_name!(params[:id])
    rescue Exception => e
      @page = Page.find_by_id!(params[:id])
    end
    @blocks = @page.blocks.paginate :all, :conditions => {:is_enabled => true}, :page => params[:page], :order => "name", :per_page => 9
  end
end
