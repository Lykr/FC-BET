function data_output = normalize_data(data_input, mu, sig)

data_size = numel(data_input);
data_output = cell(data_size, 1);

for i = 1 : data_size
    data_output{i} = (data_input{i} - mu) ./ sig;
end

end

