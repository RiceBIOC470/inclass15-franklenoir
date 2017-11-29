% GB comments
Step1 0 Need to provide code or a separate image file showing you imported and saved the images separately. 
Step2 100 
Step3 50 Need to use cat function to overlay images correctly
Step4 90 should really use segmented images for this step. 
Step5 100
Step6 100 
Step7 100 
Step8 100
Overall 80


%% step 1: write a few lines of code or use FIJI to separately save the
% nuclear channel of the image Colony1.tif for segmentation in Ilastik

%already done

%% step 2: train a classifier on the nuclei
% try to get the get nuclei completely but separe them where you can
% save as both simple segmentation and probabilities

%completed in ilastik

%% step 3: use h5read to read your Ilastik simple segmentation
% and display the binary masks produced by Ilastik 
data = h5read('inclass15.h5','/exported_data');
data = squeeze(data);
imshow(data, []);

% (datasetname = '/exported_data')
% Ilastik has the image transposed relative to matlab
% values are integers corresponding to segmentation classes you defined,
% figure out which value corresponds to nuclei

%Values > 0 correspond to cell nuclei. 

%% step 3.1: show segmentation as overlay on raw data

figure;
img = imread('48hColony1_DAPI.tif');
imshow(img, []);
hold on;
imshow(data, []);
hold off;


%% step 4: visualize the connected components using label2rgb
% probably a lot of nuclei will be connected into large objects

RGB = label2rgb(img);

imshow(RGB);

%% step 5: use h5read to read your Ilastik probabilities and visualize

data2 = h5read('Prediction for Label 2.h5','/exported_data/');
data2 = squeeze(data2);
imshow(data2);

% it will have a channel for each segmentation class you defined

%% step 6: threshold probabilities to separate nuclei better

thres = data2 > 0.999;
imshow(thres);

%% step 7: watershed to fill in the original segmentation (~hysteresis threshold)
%cant find hysteresis matlab documentation, using erosion of the mask
%watershed method instead (from inclass 14).

CC = bwconncomp(thres);
stats = regionprops(CC,'Area');
area = [stats.Area];

s = round(1.2*sqrt(mean(area))/pi);
erodemask = imerode(thres,strel('disk',s));
outside = ~imdilate(thres,strel('disk',1));
basin = imcomplement(bwdist(outside));
basin = imimposemin(basin,erodemask|outside);
L = watershed(basin);
imshow(L, [])

%% step 8: perform hysteresis thresholding in Ilastik and compare the results
% explain the differences

%The hysteresis method in Ilastik appears to seperate the cells better than
%the erosion of the mask watershed method. The mask erosion method yielded 
%large blobs however the Ilastik image appears to have a lot more noise in 
%the outer parts of the plate. The cell blobs appear more seperated and 
%unique in the Ilastik image.

%% step 9: clean up the results more if you have time 
% using bwmorph, imopen, imclose etc

%imerode and imdilate were using in step 7
L = watershed(basin);
L = imopen(L,strel('disk',5));
L = imclose(L,strel('disk',3));
imshow(L, [])

%Noise reduced


