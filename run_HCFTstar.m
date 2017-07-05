function results = run_HCFTstar(seq, res_path, bSaveImage)

% RUN_HCFTstar:
% process a sequence using HCFTstar (Correlation filter tracking with convolutional features)
%
% Input:
%     - seq:        sequence name
%     - res_path:   result path
%     - bSaveImage: flag for saving images
% Output:
%     - results: tracking results, position prediction over time
%
%   It is provided for educational/researrch purpose only.
%   If you find the software useful, please consider cite our paper.
%
%   Hierarchical Convolutional Features for Visual Tracking
%   Chao Ma, Jia-Bin Huang, Xiaokang Yang, and Ming-Hsuan Yang
%   IEEE International Conference on Computer Vision, ICCV 2015
%
%   Robust Visual Tracking via Hierarchical Convolutional Features
%   Chao Ma, Jia-Bin Huang, Xiaokang Yang, and Ming-Hsuan Yang
%   Submitted to IEEE Transactions on Pattern Analysis and Machine Intellegince
%
%
% Contact:
%   Chao Ma (chaoma99@gmail.com), or
%   Jia-Bin Huang (jbhuang1@illinois.edu).

% ================================================================================
% Environment setting
% ================================================================================

% Image file names
img_files = seq.s_frames;
% Seletected target size
target_sz = [seq.init_rect(1,4), seq.init_rect(1,3)];
% Initial target position
pos       = [seq.init_rect(1,2), seq.init_rect(1,1)] + floor(target_sz/2);

% Extra area surrounding the target for including contexts
padding = struct('generic', 1.8, 'large', 1, 'height', 0.4);

lambda = 1e-4;              % Regularization
output_sigma_factor = 0.1;  % Spatial bandwidth (proportional to target)

interp_factor = 0.01;       % Model learning rate
cell_size = 4;              % Spatial cell size

video_path='';

addpath('utility','train');
addpath(genpath('piotr_toolbox'));
addpath(genpath('edgesbox'));
addpath(genpath('Diagnose'));

vl_setupnn();

show_visualization=false;
config.kernel_sigma = 1;
config.motion_thresh= 0.181; %0.25 for singer2 0.32;%0.15
config.appearance_thresh=0.38; %0.38
config.features.hog_orientations = 9;
config.features.cell_size = 4;   % size of hog grid cell		
config.features.window_size = 6; % size of local region for intensity historgram  
config.features.nbins=8; 
% ================================================================================
% Main entry function for visual tracking
% ================================================================================
% [positions, time] = tracker_ensemble(video_path, img_files, pos, target_sz, ...
%     padding, lambda, output_sigma_factor, interp_factor, ...
%     cell_size, show_visualization);
[positions, time, rect_position] = tracker_HCFTstar(video_path, img_files, pos, target_sz, ...
            padding, lambda, output_sigma_factor, interp_factor, ...
            cell_size, show_visualization,config);
% ================================================================================
% Return results to benchmark, in a workspace variable
% ================================================================================
rects      = [positions(:,2) - target_sz(2)/2, positions(:,1) - target_sz(1)/2];
rects(:,3) = target_sz(2);
rects(:,4) = target_sz(1);
results.type   = 'rect';
results.res    = rect_position;
results.fps    = numel(img_files)/time;

end

