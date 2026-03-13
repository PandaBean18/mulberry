class CalendarEntriesController < AuthenticatedController
    def index
        entries = @current_user.calendar_entries.includes(deliverable: {campaign_participant: :campaign}).order(date: :asc)

        render json: entries.as_json(
            include: {
                deliverable: {
                    include: {
                        campaign_participant: {
                            include: { campaign: {only: [:id, :title]} }
                        }
                    }, 
                    only: [:id]
                }
            }
        )
    end

    def create
        deliverable_id = calendar_entry_params[:deliverable_id]

        if (deliverable_id != nil)
            @deliverable = Deliverable.find_by(id: deliverable_id)
            if (!@deliverable || @deliverable.campaign_participant.creator_id != @current_user.id)
                return render json: { error: "Invalid deliverable ID" }, status: :forbidden
            end

            title = ""

            if (@deliverable.status == 'pending')
                title = "#{@deliverable.deliverable_type.titleize} Draft Upload"
            elsif (@deliverable.status == "approved")
                title = "Post #{@deliverable.deliverable_type.titleize} on Socials"
            else
                title = "Reupload #{@deliverable.deliverable_type.titleize}"
            end

            brief = "For #{@deliverable.title}"

            @calendar_entry = CalendarEntry.new(
                    brief: brief, 
                    title: title, 
                    date: calendar_entry_params[:date],
                    deliverable_id: @deliverable.id,
                    entry_type: calendar_entry_params[:entry_type],
                    is_completed: calendar_entry_params[:is_completed],
                    user_id: @current_user.id
                )

            if @calendar_entry.save 
                return render json: @calendar_entry, status: :created
            else 
                return render json: @calendar_entry.errors, status: :unprocessable_entity
            end
            
        end
        @calendar_entry = CalendarEntry.new(calendar_entry_params.merge(user_id: @current_user.id))

        if @calendar_entry.save 
            return render json: @calendar_entry, status: :created
        else 
            return render json: @calendar_entry.errors, status: :unprocessable_entity
        end
    end

    private 

    def calendar_entry_params
        params.require(:calendar_entry).permit(:brief, :date, :deliverable_id, :entry_type, :title, :is_completed)
    end
end