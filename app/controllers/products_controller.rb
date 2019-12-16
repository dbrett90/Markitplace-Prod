class ProductsController < ApplicationController
    # Lots of questions on this one. Can certainly reference the books 
    #controller in the sample app, but that also allows a user to create new
    #books which I don't think we want. Need to make a decision about how much to include
 #Updated to allow users to access a library
 before_action :set_product, only: [:show, :edit, :update, :destroy, :library]
#  before_action :authenticate_user!, except: [:index, :show]
#This is what the Devise action basically does.
before_action :logged_in_user, except: [:index, :show]

 # GET /products
 def index
   @products = Product.all
 end

 # GET /products/1
 # GET /products/1.json
 def show
 end

 # GET /products/new
 def new
    #What is te current_user equivalent? See if this works
    current_user = User.find(params[:id])
    @product = current_user.products.build
 end

 # GET /products/1/edit
 def edit
 end

 # POST /products
 # POST /books.json
 def create
    #Essentially trying to replicate devise here.
    #Let's confirm that this actually pulls the current user. 
    current_user = User.find(params[:id])
    @product = current_user.books.build(product_params)

   respond_to do |format|
     if @product.save
       format.html { redirect_to @product, notice: 'Product was successfully created.' }
       format.json { render :show, status: :created, location: @product }
     else
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

 #Add and remove products from Library for the current user
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
        redirect_to book_path(@product), notice: "Looks like something went wrong! Use the contact form if this continues to cause issues."
 end

 private
   # Use callbacks to share common setup or constraints between actions.
   def set_product
    #Grab the current product
    @product = Product.find(params[:id])
   end

   # Never trust parameters from the scary internet, only allow the white list through.
   def product_params
    #Put something in here about the stripe_id or unnecessary?
    #make sure to review the entire controller
     params.require(:product).permit(:name, :description, :price, :thumbnail, :user_id)
   end
 end
end

