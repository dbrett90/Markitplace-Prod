class PlanTypesController < ApplicationController
    #Updated to allow users to access a library
 before_action :set_plan, only: [:show, :edit, :update, :destroy, :library]
 before_action :logged_in?, except: [:index,]
#  before_action :authenticate_user!, except: [:index, :show]
#This is what the Devise action basically does.
#before_action :logged_in_user, except: [:index, :show]

#  def plans 
#  end
 # GET /plans
 def index
   @plan_types = PlanType.all
   @products = Product.all
   #Test that products is an array that you can access
   flash[:notice] = "Number of Plans: ", @plan_types.count
   flash[:danger] = "Number of Products", @products.count
 end

 # GET /plans/1
 # GET /plans/1.json
#  def show
#  end

 # GET /plans/new
 def new
    #What is te current_user equivalent? See if this works
    @plan_type = current_user.plan_types.build
 end

 # GET /plans/1/edit
 def edit
 end

 # POST /plans
 # POST /plans.json
#Essentially trying to replicate devise here.
#Let's confirm that this actually pulls the current user. 
 def create
    @plan_type = current_user.plan_types.build(plan_type_params)
   respond_to do |format|
     if @plan_type.save
       flash[:successful] = "PLAN TYPE WAS SUCCESSFULLY CREATED"
       format.html { redirect_to @plan_type, notice: 'PLAN TYPE was successfully created.' }
       format.json { render :show, status: :created, location: @plan_type }
     else
       flash[:danger] = "SOME TYPE OF ISSUE WITH CREATION"
       flash[:notice] = @plan_type.errors.full_messages
       format.html { render :new }
       format.json { render json: @plan_type.errors, status: :unprocessable_entity }
     end
   end
 end

 # PATCH/PUT /books/1
 # PATCH/PUT /books/1.json
 def update
   respond_to do |format|
     if @plan_type.update(plan_type_params)
       format.html { redirect_to @plan_type, notice: 'PLAN was successfully updated.' }
       format.json { render :show, status: :ok, location: @plan_type }
     else
       format.html { render :edit }
       format.json { render json: @plan_type.errors, status: :unprocessable_entity }
     end
   end
 end

 # DELETE /books/1
 # DELETE /books/1.json
 def destroy
   @plan_type.destroy
   respond_to do |format|
     format.html { redirect_to plan_types_url, notice: 'PLAN was successfully destroyed.' }
     format.json { head :no_content }
   end
 end

 #Add and remove plans from Library for the current user
 def library
    # current_user = User.find(params[:id])
    type = params[:type]
    if type=="add"
        #Add the plan to the library additions array - need to change this
        current_user.plan_subscription_library_additions << @plan_type
        redirect_to pplan_subscription_library_index_path, notice: "#{@plan_type.name} was added to your active subscriptions!"
    elsif type=="remove"
        current_user.plan_subscription_library_additions.delete(@plan_type)
        redirect_to root_path, notice: "#{@plan_type.name} was removed from your active subscriptions. you will no longer be charged"
    else
        #type is missing, nothing should happen
        redirect_to plan_type_path(@plan_type), notice: "Looks like something went wrong! Use the contact form if this continues to cause issues."
    end
 end

 private
   # Use callbacks to share common setup or constraints between actions.
   #Grab the current plan_type
   def set_plan_type
    @plan_type = PlanType.find(params[:id])
   end

   # Never trust parameters from the scary internet, only allow the white list through.
    #Update with User ID?
   def plan_type_params
     params.require(:plan_type).permit(:name, :description, :created_at, :updated_at, :plan_id, :thumbnail)
   end
end
