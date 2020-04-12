class Api::V1::JobsController < Api::V1::BaseController
    
    before_action :authenticate_with_token!

    def index
        jobs = current_user.jobs  
        render json: { jobs: jobs }, status: 200
    end

    def show
        job = current_user.jobs.find(params[:id])
        render json: job, status: 200
    end    

    def create
        job = current_user.jobs.build(job_params)
       
        if job.save
            render json: job, status:201
        else
            render json: { errors: job.errors },status:422
        end    
    end

    def update
        job = current_user.jobs.find(params[:id])

        if job.update_attributes(job_params)
            render json: job, status: 200
        else
            render json: { errors: job.errors}, status:422
        end        
    end

    def destroy
        job = current_user.jobs.find(params[:id])
        
        job.destroy
        
        head 204
    end


    private

    def job_params
        params.require(:job).permit(:title,:description,:deadline,:done)
    end    

end
