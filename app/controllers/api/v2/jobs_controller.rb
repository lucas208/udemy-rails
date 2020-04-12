class Api::V2::JobsController < Api::V2::BaseController
    
    before_action :authenticate_user!

    def index
        #byebug
        jobs = current_user.jobs.ransack(params[:q]).result  
        render json: jobs, status: 200
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
