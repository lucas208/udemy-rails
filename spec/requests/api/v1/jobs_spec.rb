require 'rails_helper'

RSpec.describe 'Jobs API' do
    before { host! 'api.task.test' }

    let!(:user) { create (:user) }
    let(:headers) do
        {
            'Accept' => 'application/vnd.task.v1',
            'Content-Type' => Mime[:json].to_s,
            'Authorization' => user.auth_token
        }
    end   

    describe 'GET /jobs' do
        before do
            create_list(:job, 5 , user_id: user.id)
            get '/jobs', params: {}, headers: headers
        end

        it 'returns status code 200' do
            expect(response).to have_http_status(200)      
        end

        it 'returns 5 jobs from database' do
            expect(json_body[:jobs].count).to eq(5)
        end

    end

    describe 'GET /jobs/:id' do
        
        let(:job) { create(:job, user_id: user.id) }

        before { get "/jobs/#{job.id}", params: {}, headers: headers}

        it 'returns status code 200' do
            expect(response).to have_http_status(200)    
        end

        it 'returns the json for job' do
            expect(json_body[:title]).to eq(job.title) 
        end

    end

    describe 'POST /jobs' do
        
        before do
            post '/jobs', params: {job: job_params}.to_json, headers: headers
        end

        context 'when the params are valid' do
            
            let(:job_params) { attributes_for(:job) }

            it 'returns status code 201' do
                expect(response).to have_http_status(201)
            end

            it 'saves the job in the database' do
                expect( Job.find_by(title: job_params[:title]) ).not_to be_nil
            end

            it 'returns the json for the created job' do
                expect(json_body[:title]).to eq(job_params[:title])
            end
            
            it 'assigns the created job to the current user' do
                expect(json_body[:user_id]).to eq(user.id)
            end
        end   
        
        context 'when the params are invalid' do
            let(:job_params) { attributes_for(:job, title: ' ') }
        
            it 'returns status code 422' do
                expect(response).to have_http_status(422)
            end

            it 'does note save the job in the database' do
                expect( Job.find_by(title: job_params[:title]) ).to be_nil
            end

            it 'returns json error for title' do
                expect(json_body[:errors]).to have_key(:title)
            end

        end

    end

    describe 'PUT /jobs/:id' do
        let!(:job) { create(:job, user_id: user.id) }
        
        before do
            put "/jobs/#{job.id}", params: { job: job_params }.to_json, headers: headers
        end   
        
        context 'when the params are valid' do
            let(:job_params){ { title: 'New job title' } }
            
            it 'returns status code 200' do
                expect(response).to have_http_status(200)
            end

            it 'returns the job in the database' do
                expect(json_body[:title]).to eq(job_params[:title])
            end

            it 'updates the job in the database' do
                expect(Job.find_by(title: job_params[:title])).not_to be_nil
            end

        end

        context 'when the params are invalid' do
            let(:job_params){ { title: ' ' } }
            
            it 'returns status code 422' do
                expect(response).to have_http_status(422)
            end

            it 'returns the json error for title' do
                expect(json_body[:errors]).to have_key(:title)
            end

            it 'does not update the job in the database' do
                expect(Job.find_by(title: job_params[:title])).to be_nil
            end

        end
        
    end

    describe 'DELETE /jobs/:id' do
        let!(:job) { create(:job, user_id: user.id) }

        before do
            delete "/jobs/#{job.id}", params: {}, headers: headers
        end    

        it 'return status code 204' do
            expect(response).to have_http_status(204)
        end   
        
        it 'removes the job from the database' do
            expect { Job.find(job.id)}.to raise_error(ActiveRecord::RecordNotFound) 
            #expect(Job.find_by(id: job.id)).to be_nil
        end 
    end    

end
