class MessagesController < ApplicationController
  before_action :set_message, only: %i[show edit update destroy]

  # GET /messages
  def index
    if params[:room_id]
      @room = Room.find(params[:room_id])
      @messages = @room.messages.includes(:user)
    else
      @messages = []
    end
  end
  

  # GET /messages/1
  def show
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  def create
    @message = current_user.messages.build(message_params)
  
    respond_to do |format|
      if @message.save

        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend("room-messages-#{@message.room_id}", partial: "messages/message", locals: { message: @message })
        end
  
        format.html { redirect_to @message.room, notice: "Message was successfully created." }
        format.json { render :show, status: :created, location: @message }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("message_form", partial: "messages/form", locals: { message: @message })
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end
  
  

  # PATCH/PUT /messages/1
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to @message, notice: "Message was successfully updated." }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  def destroy
    @message.destroy!

    respond_to do |format|
      @message.broadcast_remove_to @message.room, target: "message_#{@message.id}"
      
      format.turbo_stream { render turbo_stream: turbo_stream.remove("message_#{@message.id}") }
      format.html { redirect_to messages_path, status: :see_other, notice: "Message was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # ใช้ callback เพื่อหา message ตาม ID
  def set_message
    @message = Message.find(params[:id])
  end

  # กำหนดให้รับเฉพาะพารามิเตอร์ที่ต้องการ
  def message_params
    params.require(:message).permit(:content, :room_id)
  end
end
