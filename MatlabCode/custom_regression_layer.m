classdef custom_regression_layer < nnet.layer.RegressionLayer
    
    properties
        % (Optional) Layer properties.
        
        % Layer properties go here.
        bs_beam_info = struct();
        veh_beam_info = struct();
    end
    
    methods
        function layer = myRegressionLayer()
            % (Optional) Create a myRegressionLayer.
            
            % Layer constructor function goes here.
        end
        
        function loss = forwardLoss(layer, Y, T)
            % Return the loss between the predictions Y and the training
            % targets T.
            %
            % Inputs:
            %         layer - Output layer
            %         Y     ? Predictions made by network
            %         T     ? Training targets
            %
            % Output:
            %         loss  - Loss between Y and T
            
            % Layer forward loss function goes here.
            
            loss = mean(1/2 * (1-cos(Y-T)), 'all');
            
            
%             loss_aoas = 0;
%             loss_aods = 0;
%             
%             n = length(T);
%             nt = size(layer.bs_beam_info.beam_book, 1);
%             nr = size(layer.veh_beam_info.beam_book, 1);
%             
%             for i = 1 : n
%                 if Y(1, i) ~= T(1, i)
%                     pha_a = cos(Y(1, i))-cos(T(1, i));
%                     pha_as = [0 : pi * pha_a : (nr-1)*pi*pha_a];
%                     a_real = sum(cos(pha_as));
%                     a_imag = sum(sin(pha_as));
%                     loss_aoas = loss_aoas + 1 - sqrt(a_real^2 + a_imag^2) / nr;
%                 end
%                 
%                 if Y(2, i) ~= T(2, i)
%                     pha_d = cos(Y(2, i))-cos(T(2, i));
%                     pha_ds = [0 : pi * pha_d : (nr-1)*pi*pha_d];
%                     d_real = sum(cos(pha_ds));
%                     d_imag = sum(sin(pha_ds));
%                     loss_aods = loss_aods + 1 - sqrt(d_real^2 + d_imag^2) / nt;
%                 end
%             end
%             
%             loss = loss_aoas + loss_aods;
        end
    end
end