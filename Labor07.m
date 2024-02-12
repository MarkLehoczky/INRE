
clear

happyImgs = dir('happy*.png');
happy_labels = categorical(repmat(0,numel(happyImgs),1));

sadImgs = dir('sad*.png');
sad_labels = categorical(repmat(1,numel(happyImgs),1));

labels = [happy_labels; sad_labels;];
imdsTest = imageDatastore({'happy*.png' 'sad*.png'},'Labels',labels);


% Augmentation

for i = 1:length(imdsTest.Files)
    [~, filename, extension] = fileparts(imdsTest.Files{i});
    path = "aug_" + filename;
    image = imread(imdsTest.Files{i});
    white = imread("white.png");
    
    % Rotates the orginal image, then rotates a white image, inverses the
    % colors (therefore the added black pixels turn to white), then places
    % the white pixels to the rotated image, with that changing the created
    % black pixels to white
    imwrite(imoverlay(imrotate(image, 10, "bilinear", "crop"), im2bw(imcomplement(imrotate(white, 10, "bilinear", "crop"))), "white"), path + "_01.png", 'png');
    imwrite(imoverlay(imrotate(image, -10, "bilinear", "crop"), im2bw(imcomplement(imrotate(white, -10, "bilinear", "crop"))), "white"), path + "_02.png", 'png');
    imwrite(imoverlay(imrotate(image, 20, "bilinear", "crop"), im2bw(imcomplement(imrotate(white, 20, "bilinear", "crop"))), "white"), path + "_03.png", 'png');
    imwrite(imoverlay(imrotate(image, -20, "bilinear", "crop"), im2bw(imcomplement(imrotate(white, -20, "bilinear", "crop"))), "white"), path + "_04.png", 'png');
    
    % Moves the original image on the x and y axes
    imwrite(imtranslate(image, [0, 25],'FillValues',255), path + "_05.png", 'png');
    imwrite(imtranslate(image, [0, -25],'FillValues',255), path + "_06.png", 'png');
    imwrite(imtranslate(image, [25, 0],'FillValues',255), path + "_07.png", 'png');
    imwrite(imtranslate(image, [-25, 0],'FillValues',255), path + "_08.png", 'png');
    imwrite(imtranslate(image, [25, 25],'FillValues',255), path + "_09.png", 'png');
    imwrite(imtranslate(image, [25, -25],'FillValues',255), path + "_10.png", 'png');
    imwrite(imtranslate(image, [-25, 25],'FillValues',255), path + "_11.png", 'png');
    imwrite(imtranslate(image, [-25, -25],'FillValues',255), path + "_12.png", 'png');

    % Same actions as before, but the original image is flipped vertically
    imwrite(flip(imoverlay(imrotate(image, 10, "bilinear", "crop"), im2bw(imcomplement(imrotate(white, 10, "bilinear", "crop"))), "white"), 2), path + "_13.png", 'png');
    imwrite(flip(imoverlay(imrotate(image, -10, "bilinear", "crop"), im2bw(imcomplement(imrotate(white, -10, "bilinear", "crop"))), "white"), 2), path + "_14.png", 'png');
    imwrite(flip(imoverlay(imrotate(image, 20, "bilinear", "crop"), im2bw(imcomplement(imrotate(white, 20, "bilinear", "crop"))), "white"), 2), path + "_15.png", 'png');
    imwrite(flip(imoverlay(imrotate(image, -20, "bilinear", "crop"), im2bw(imcomplement(imrotate(white, -20, "bilinear", "crop"))), "white"), 2), path + "_16.png", 'png');
    imwrite(flip(imtranslate(image, [0, 25],'FillValues',255), 2), path + "_17.png", 'png');
    imwrite(flip(imtranslate(image, [0, -25],'FillValues',255), 2), path + "_18.png", 'png');
    imwrite(flip(imtranslate(image, [25, 0],'FillValues',255), 2), path + "_19.png", 'png');
    imwrite(flip(imtranslate(image, [-25, 0],'FillValues',255), 2), path + "_20.png", 'png');
    imwrite(flip(imtranslate(image, [25, 25],'FillValues',255), 2), path + "_21.png", 'png');
    imwrite(flip(imtranslate(image, [25, -25],'FillValues',255), 2), path + "_22.png", 'png');
    imwrite(flip(imtranslate(image, [-25, 25],'FillValues',255), 2), path + "_23.png", 'png');
    imwrite(flip(imtranslate(image, [-25, -25],'FillValues',255), 2), path + "_24.png", 'png');
    imwrite(flip(image, 2), path + "_25.png", 'png');
end


happyImgs = dir('aug_happy*.png');
happy_labels = categorical(repmat(0,numel(happyImgs),1));

sadImgs = dir('aug_sad*.png');
sad_labels = categorical(repmat(1,numel(happyImgs),1));

labels = [happy_labels; sad_labels;];
imdsTrain = imageDatastore({'aug_happy*.png' 'aug_sad*.png'},'Labels',labels);


figure
numImages = length(imdsTest.Files);
perm = randperm(numImages,length(imdsTest.Files));
for i = 1:length(imdsTest.Files)
    subplot(2,length(imdsTest.Files)/2,i);
    imshow(imdsTest.Files{perm(i)});
end

% The original images are the test images, and the augmented images are the
% training images.

%[imdsTrain,imdsTest] = splitEachLabel(imds,0.8,'randomize');

layers = [ ...
    imageInputLayer([256 256 3])
    convolution2dLayer(5,20)
    reluLayer
    maxPooling2dLayer(2,'Stride',2)
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

options = trainingOptions('sgdm', ...
    'MaxEpochs',50,...
    'InitialLearnRate',1e-4, ...
    'Verbose',0, ...
    'Plots','training-progress');

net = trainNetwork(imdsTrain,layers,options);

YPred = classify(net,imdsTest);
YTest = imdsTest.Labels;

accuracy = sum(YPred == YTest)/numel(YTest)
