classdef custom_regression < nnet.layer.RegressionLayer
        
    properties
        % (Optional) Layer properties.

        % Layer properties go here.
        Mt = 0;
        Mr = 0;
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
            %         Y     每 Predictions made by network
            %         T     每 Training targets
            %
            % Output:
            %         loss  - Loss between Y and T

            % Layer forward loss function goes here.
%             loss = mean((cos(Y) - cos(T)) .^ 2, 'all');
            loss = 1/(layer.Mt + layer.Mr) * mean(layer.Mr.*(Y(1,:) - T(1,:)).^2 + layer.Mt.*(Y(2,:) - T(2,:)).^2);
        end
        
%         function dLdY = backwardLoss(layer, Y, T)
%             % (Optional) Backward propagate the derivative of the loss 
%             % function.
%             %
%             % Inputs:
%             %         layer - Output layer
%             %         Y     每 Predictions made by network
%             %         T     每 Training targets
%             %
%             % Output:
%             %         dLdY  - Derivative of the loss with respect to the 
%             %                 predictions Y        
% 
%             % Layer backward loss function goes here.
%         end
    end
end