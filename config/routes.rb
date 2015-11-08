Rails.application.routes.draw do
    
 root :to => "collector#collect"
 
 get ":controller(/:action(/:id))"
 post ":controller(/:action(/:id))"

end
