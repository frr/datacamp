# Field Descriptions
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

class FieldDescriptionsController < ApplicationController
  before_filter :get_dataset_description
  protect_from_forgery :except => 'order'
  
  def index
  end
  
  def new
    @field_description = @dataset_description.field_descriptions.build
    
    respond_to do |wants|
      wants.html
      wants.js
    end
  end
  
  def create
    # Special case when we wanna automagically create description for some field
    
    @field_description = @dataset_description.field_descriptions.build(params[:field_description])
        
    saved = @field_description.save
    respond_to do |wants|
      wants.html do
        if saved
          return redirect_to new_dataset_description_field_description_path(@dataset_description) if params[:commit] == I18n.t("global.save_and_create")
          return redirect_to @dataset_description
        else
          render :action => 'new'
        end
      end
      wants.js
    end
  end
  
  def destroy
    @field_description = FieldDescription.find_by_id(params[:id])
    @field_description.destroy
    redirect_to @dataset_description
  end
  
  def edit
    @field_description = FieldDescription.find_by_id(params[:id])
    
    respond_to do |wants|
      wants.html
      wants.js
    end
  end
  
  # PUT /dataset_descriptions/1/attributes/1
  def update
    @field_description = FieldDescription.find_by_id(params[:id])
    
    respond_to do |format|
      if @field_description.update_attributes(params[:field_description])
        flash[:notice] = I18n.t("dataset.description_updated")
        format.html {
          return redirect_to new_dataset_description_field_description_path(@dataset_description) if params[:commit] == I18n.t("global.save_and_create")
          return redirect_to(@dataset_description) 
        }
        format.xml  { head :ok }
        format.js
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dataset_description.errors, :status => :unprocessable_dataset_description }
        format.js
      end
    end
  end
  
  # POST /dataset_descriptions/1/attributes/order
  # Saves order
  def order
    weight = 1
    ids = params[:order].split(',')
    ids.each do |id|
      begin
        ea = FieldDescription.find(id)
        ea.weight = weight
        ea.save(false)
        weight += 1
      rescue
        next
      end
    end
    render :nothing => true
  end
  
  def create_for_column
    dataset = @dataset_description.dataset
    column = dataset.dataset_record_class.columns.find { |c| c.name == params[:column] }
    dataset.create_description_for_column(column)
    respond_to do |wants|
      wants.html do
        # FIXME: LOCALIZE: dataset.column_created_message
        flash[:notice] = "Created column #{column.name}"
        redirect_to request.referer
      end
      wants.js
    end
  end
  
  def create_column
    dataset = @dataset_description.dataset
    @field_description = @dataset_description.field_descriptions.find_by_identifier!(params[:id])
    dataset.create_column_for_description(@field_description)
    respond_to do |wants|
      wants.html do
        # FIXME: LOCALIZE: dataset.column_created_message
        flash[:notice] = "Created column #{@field_description.identifier}"
        redirect_to request.referer
      end
      wants.js
    end
  end
  
  protected
  
  def get_dataset_description
    @dataset_description = DatasetDescription.find_by_id!(params[:dataset_description_id])
  end
end