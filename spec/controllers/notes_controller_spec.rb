require 'rails_helper'

RSpec.describe NotesController, type: :controller do
  describe "notes#index action" do
    it "should successfully respond" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "should return Notes in response" do
      Note.create(content: 'This is a note.')
      get :index
      json = JSON.parse(response.body)
      expect(json.length).to be >= 1
    end
  end

  describe "notes#create action" do
    before do
      post :create, params: { note: { content: 'Hello' } }
    end

    it "should return 200 status-code" do
      expect(response).to be_success
    end

    it "should successfully create and save a new note in our database" do
      note = Note.last
      expect(note.content).to eq('Hello')
    end

    it "should return the created note in response body" do
      json = JSON.parse(response.body)
      expect(json['content']).to eq('Hello')
    end

    it "should properly deal with validation errors" do
      post :create, params: { note: { content: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "should return error json on validation error" do
      post :create, params: { note: { content: '' } }
      json = JSON.parse(response.body)
      expect(json).to include("errors")
    end
  end

  describe "notes#show action" do
    before do
      @note = Note.create(content: 'Show this note.')
      @tag = Tag.create(name: 'Show this tag.', note_id: @note.id)
      get :show, params: { id: @note.id }
      @json = JSON.parse(response.body)
    end

    it "should receive correct note in response" do
      expect(@json['id']).to eq(@note.id)
    end

    it "should include associated tags in response" do
      expect(@json['tags']).to eq([{"name" => @tag.name}])
      # expect(@json['tags'][0]['name']).to eq(@tag.name)
    end
  end

  describe "notes#update action" do
    before do
      @note = Note.create(content: 'Show this note.')
    end

    it "should recieve the updated note in response" do
      put :update, params: { id: @note.id, note: { content: 'Updated this note.'} }
      json = JSON.parse(response.body)
      expect(json['content']).to eq('Updated this note.')
    end

    it "should properly deal with validation errors" do
      put :update, params: { id: @note.id, note: { content: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "notes#destroy action" do
    it "should destroy saved note" do
      note = Note.create(content: 'This will be deleted.')
      delete :destroy, params: { id: note.id }
      expect(response).to be_success
      note = Note.find_by_id(note.id)
      expect(note).to eq nil
    end

    it "should return :no_content" do
      note = Note.create(content: 'This will be deleted.')
      delete :destroy, params: { id: note.id }
      expect(response).to have_http_status(:no_content)
    end
  end
end
