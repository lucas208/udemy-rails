require 'rails_helper'

RSpec.describe 'Jobs API' do
    before { host! 'api.task.test' }

    let!(:user) { create (:user) }
    let!(:auth_data){ user.create_new_auth_token }
    let(:headers) do
        {
            'Accept' => 'application/vnd.task.v2',
            'Content-Type' => Mime[:json].to_s,
            'access-token' => auth_data['access-token'],
            'uid' => auth_data['uid'],
            'client' => auth_data['client']
        }
    end   

    describe 'GET /jobs' do
       context 'when no filter param is sent' do
            before do
                create_list(:job, 5 , user_id: user.id)
                get '/jobs', params: {}, headers: headers
            end

            it 'returns status code 200' do
                expect(response).to have_http_status(200)      
            end

            it 'returns 5 jobs from database' do
                expect(json_body[:data].count).to eq(5)
            end
       end 

       context 'when filter and sorting params are sent' do
            let!(:notebook_job_1) { create(:job, title:'Check if the notebook is broken', user_id: user.id)}
            let!(:notebook_job_2) { create(:job, title:'Buy a new notebook', user_id: user.id)}
            let!(:other_job_1) { create(:job, title:'Fix the door', user_id: user.id)}
            let!(:other_job_2) { create(:job, title:'Buy a new car', user_id: user.id)}

            before do
                get '/jobs?q[title_cont]=note&q[s]=title+ASC', params: {}, headers: headers
            end

            it 'returns only the jobs matching in the correct order' do
                returned_job_titles = json_body[:data].map { |j| j[:attributes][:title] }

                expect(returned_job_titles).to eq([notebook_job_2.title ,notebook_job_1.title])
            end
       end
    end

    describe 'GET /jobs/:id' do
        
        let(:job) { create(:job, user_id: user.id) }

        before { get "/jobs/#{job.id}", params: {}, headers: headers}

        it 'returns status code 200' do
            expect(response).to have_http_status(200)    
        end

        it 'returns the json for job' do
            expect(json_body[:data][:attributes][:title]).to eq(job.title) 
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
                expect(json_body[:data][:attributes][:title]).to eq(job_params[:title])
            end
            
            it 'assigns the created job to the current user' do
                expect(json_body[:data][:attributes][:'user-id']).to eq(user.id)
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
                expect(json_body[:data][:attributes][:title]).to eq(job_params[:title])
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
