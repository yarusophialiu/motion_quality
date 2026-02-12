current_path = fileparts(mfilename('fullpath'));

addpath(current_path);
addpath([current_path '/core']);
addpath([current_path '/core/processing']);
addpath([current_path '/core/trials']);
addpath([current_path '/core/utils']);
addpath([current_path '/plotting']);

if ~exist('Edf2Mat')
    warning('deps/uzh-edf-converter needs to be added manually');
end