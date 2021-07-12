try
    try
        stop(vid)
        flushdata(vid);
        delete(vid);
        clear all
        close all force hidden
    catch
        flushdata(vid);
        delete(vid);
        clear all
        close all force hidden
    end
catch
    clear all
    close all force hidden
end

warning('off', 'MATLAB:MKDIR:DirectoryExists');

name_of_experiment = 'blue_exposure_testing';
mkdir(name_of_experiment);

number_images_per_session = 25; % usually 25 12bef 12aft
time_between_images = 0; % usually 5
excitation_light_exposure = 9; % usually 9
number_of_sessions = 7; % how long ti will run 
time_between_sessions = 3600*8; % in seconds 3600->repeat every hour
warm_up_amout = 60*5;
red_DAC = 0;
blue_DAC = 1;


vid = videoinput('tisimaq_r2013_64', 1, 'Y800 (5472x3648)');
src = getselectedsource(vid);

vid.FramesPerTrigger = 1;

% it takes into account amount of time that has passed during each session
% as well, so if you want recording every hour just put in 3600 seconds 

% make sure everything is off
LabJack_cycle(red_DAC,0)
pause(0.1);
LabJack_cycle(blue_DAC,0)
pause(0.1);

images_per_iter = (number_images_per_session-1)/2;

% turn background light on for 2 minutes to help stabalize image quality

excitation_light_exposure = [9,(1:number_of_sessions)*2];

disp(['begining experiment ' name_of_experiment]);
for i=1:number_of_sessions
    
    session_timer = tic;
    
    disp(['Running session ' num2str(i)]);
    
    % warm up red leds
    disp('warming up LEDs');
    LabJack_cycle(red_DAC,5)
    pause(warm_up_amout);
    % make the session folder
    mkdir(fullfile(pwd,name_of_experiment,['session' num2str(i)]));
    
    % pre stimulus images
    disp('Pre stim imaging')
    [pre_stim_images,~] = take_N_images_every_X_seconds(src,vid,images_per_iter,time_between_images);
    
    disp(['Stimulus for ' num2str(excitation_light_exposure(i)) ' seconds']);
    % activate blue
    LabJack_cycle(blue_DAC,5);
    % start blue timer
    stimulus_timer = tic;
    % image stim image
    [stim_image,~] = take_N_images_every_X_seconds(src,vid,1,0);
    % finish image timer
    image_stim_time = toc(stimulus_timer);
    % pause for the remaining stimulus
    remaining_stimulus = excitation_light_exposure(i)-image_stim_time;
    
    if remaining_stimulus>0
        pause(remaining_stimulus)
    end
    % turn blue light stim off
    LabJack_cycle(blue_DAC,0);
    
    % post stimulus images
    disp('Post stim imaging')
    [post_stim_images,~] = take_N_images_every_X_seconds(src,vid,images_per_iter,time_between_images);

    % write images to disk
    disp('Recording data')
    images = [pre_stim_images,stim_image,post_stim_images];
    write_images_to_session(i,name_of_experiment,images)
    
    elapsedTime=toc(session_timer);
    
    disp(['Next session in ' num2str((time_between_sessions-elapsedTime)/60) ' minutes']);
    LabJack_cycle(red_DAC,0);
    LabJack_cycle(blue_DAC,0);    
    
    if isequal(i,number_of_sessions)
        break
    end
    
    pause(time_between_sessions-elapsedTime);
    
    clearvars elapsedTime;
    
    
end





% stop(vid)
