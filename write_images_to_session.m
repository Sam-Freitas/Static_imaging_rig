function write_images_to_session(session_num,name_of_experiment,images)


for i = 1:length(images)
    imwrite(images{i}, ...
        fullfile(pwd,name_of_experiment,...
        ['session' num2str(session_num)], [num2str(i) '.png']));
end


end