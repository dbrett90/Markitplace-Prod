class ProductsController < ApplicationController
 before_action :set_product, only: [:show, :edit, :update, :destroy, :library]
 before_action :admin_user, except: [:index, :show]

#  def plans 
#  end
 # GET /products
 def index
  #How to only show the products associated with the plan selected?
   @products = Product.all
  #  @plan_type = PlanType.find(params[:id])
  #  @products = @plan_type.products
   #Test that products is an array that you can access
 end

 # GET /products/1
 # GET /products/1.json
 def show
 end

 # GET /products/new
 def new
    #What is te current_user equivalent? See if this works
    #current_user = User.find(params[:id])
    @product = current_user.products.build
 end

 # GET /products/1/edit
 def edit
 end

 # POST /products
 # POST /books.json
#Essentially trying to replicate devise here.
#Let's confirm that this actually pulls the current user. 
 def create
    @product = current_user.products.build(product_params)
    # flash[:warning] = @product.plan_type_name
    #This is to link each of them together
    @plan_types = PlanType.all
    @plan_types.each do |plan_type|
      if plan_type.name.downcase == @product.plan_type_name.downcase
        # flash[:danger] = "PRODUCT", @product.plan_type
        # flash[:success] = plan_type.name
        @product.plan_type = plan_type
        plan_type.products << @product
      end
    end
   respond_to do |format|
     if @product.save
       flash[:successful] = "PRODUCT WAS SUCCESSFULLY CREATED, PLAN IS:", @product.plan_type_name
       format.html { redirect_to @product, notice: 'Product was successfully created.' }
       format.json { render :show, status: :created, location: @product }
       flash[:warning] = "PRODUCT TYPE", @product.plan_type 
     else
       flash[:danger] = "SOME TYPE OF ISSUE WITH CREATION"
       flash[:notice] = @product.errors.full_messages
       format.html { render :new }
       format.json { render json: @product.errors, status: :unprocessable_entity }
     end
   end
 end

 # PATCH/PUT /books/1
 # PATCH/PUT /books/1.json
 def update
   respond_to do |format|
     if @product.update(product_params)
       format.html { redirect_to @product, notice: 'Product was successfully updated.' }
       format.json { render :show, status: :ok, location: @product }
     else
       format.html { render :edit }
       format.json { render json: @product.errors, status: :unprocessable_entity }
     end
   end
 end

 # DELETE /books/1
 # DELETE /books/1.json
 def destroy
   @product.destroy
   respond_to do |format|
     format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
     format.json { head :no_content }
   end
 end

 #Might want to rip out this part of the controller - don't need a library method here
 def library
    # current_user = User.find(params[:id])
    type = params[:type]
    if type=="add"
        #Add the product to the library additions array
        current_user.product_subscription_library_additions << @product
        redirect_to product_subscription_library_index_path, notice: "#{@product.name} was added to your active subscriptions!"
    elsif type=="remove"
        current_user.product_subscription_library_additions.delete(@product)
        redirect_to root_path, notice: "#{@product.name} was removed from your active subscriptions. you will no longer be charged"
    else
        #type is missing, nothing should happen
        redirect_to product_path(@product), notice: "Looks like something went wrong! Use the contact form if this continues to cause issues."
    end
 end

 private
   # Use callbacks to share common setup or constraints between actions.
   #Grab the current product
   def set_product
    @product = Product.find(params[:id])
   end

   def current_plan
    @plan_type = PlanType.find(params[:id])
   end

   # Never trust parameters from the scary internet, only allow the white list through.
    #Put something in here about the stripe_id or unnecessary?
    #make sure to review the entire controller
   def product_params
     params.require(:product).permit(:name, :description, :created_at, :updated_at, :product_id, :plan_type_name, :partner_name, :calories, :protein, :servings, :fats, :thumbnail, :user_id)
   end

   def admin_user
    redirect_to(root_url) unless current_user.admin?
   end
end

