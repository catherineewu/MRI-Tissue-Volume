%MRI Upper Leg Body Fat Percentage Thingy
clc;clear;
fprintf('This program takes a black-and-white T1-weighted MRI image of a transverse section of the thigh\n')
fprintf('and displays the approximate volumes of muscle and adipose/soft tissue, along with health indicators.*\n')
fprintf('Map Key: RED = Adipose/Soft Tissue   GREEN = Muscle Tissue   BLACK = Non-muscle Tissue**   WHITE = Space\n\n')
filename = input('Enter the filename: ','s');
mri = imread(filename);
[h,w,c] = size(mri);
map = uint8(zeros(h,w,3));
%Establish region outside of legs, make outside white in map
for ii=1:1:h
    for jj=1:1:w
        if mri(ii,jj)<20
            map(ii,jj,:) = 255;
        end
    end
end
%Establish larger border region (so skin doesn't get identified) with map2
map2 = map;
s = round(h/200);
for ii=s+1:1:h-s
    for jj=s+1:1:w-s
        border = 0;
        for kk=ii-s:1:ii+s
            for ll=jj-s:1:jj+s
                if mri(kk,ll)<20
                    border = 1;
                end
            end
        end
        if border==1
            map2(ii,jj,:) = 255;
        end
    end
end
map = map2;
%Color map red for fat/soft tissue, green for muscle tissue
for ii=1:1:h
    for jj=1:1:w
        if map2(ii,jj,:)==0
            if mri(ii,jj)>25 && mri(ii,jj)<100 %Muscle (GREEN) parameters
                map(ii,jj,:) = 0;
                map(ii,jj,2) = 255;
            end
            if mri(ii,jj)>=100 %Fat/soft tissue (RED) parameters
                map(ii,jj,:) = 0;
                map(ii,jj,1) = 255;
            end
        end
    end
end
%Reduce Isolated mistaken small areas of muscle
map2 = map;
for ii=8:1:h-7
    for jj=8:1:w-7
        count = 0;
        if map(ii,jj,2)==map(ii,jj,1)+255
            for kk=ii-7:1:ii+7
                for ll=jj-7:1:jj+7
                    if map(kk,ll,2)==map(kk,ll,1)+255
                        count = count + 1;
                    end
                end
            end
            if count<90
                map2(ii,jj,:) = 0;
            end
        end
    end
end
map = map2;
%Identify Bone in Middle & Exclude from Area of Adipose/Soft Tissue
%DIAMETER (column)
outline = map;
difference = 1:1:h;
for jj=1:1:w
    postop = 0;
    posbottom = 0;
    for ii=1:1:h/2
        if map(ii,jj,3)==255 && postop==0
            top = ii;
            outline(ii,jj,:) = 0;
            outline(ii,jj,3) = 255;
            postop = 1;
        end
        if map(h-(ii-1),jj,3)==255 && posbottom==0
            bottom = ii;
            outline(ii,jj,:) = 0;
            outline(ii,jj,3) = 255;
            posbottom = 1;
        end
    end
    difference(ii) = posbottom-postop;
end
%Finding max distance and excluding outliers
z = find(difference==0);
difference(z) = [];
sorted = sort(difference);
sorted(1:(4*length(sorted))/5) = [];
middle = mean(sorted);
check = 0;
while check==0
    if max(sorted)>1.2*middle
        outlier = find(max(sorted));
        sorted(outlier) = [];
    else
        check = 1;
    end
end
%Using max distance (which is the diameter) to find area of bone
femurheight = max(sorted)/8;
femurwidth = femurheight*.75;
femurarea = round((femurwidth/2)*(femurheight/2)*pi);
%AREA CALCULATIONS OF MUSCLE AND ADIPOSE/SOFT TISSUE
fat = 0; %red
muscle = 0; %green
for ii=1:1:h
    for jj=1:1:w
        if map(ii,jj,1)==255
            if map(ii,jj,[2 3])==0
                fat = fat+1;
            end
        elseif map(ii,jj,2)==255
            if map(ii,jj,[1 3])==0
                muscle = muscle+1;
            end
        end
    end
end
fat = fat - femurarea;
%Display Data
fprintf('\nPercent Adipose/Soft Tissue:   %.2f',(fat/(fat+muscle))*100)
fprintf('\nPercent Muscle Tissue:   %.2f',(muscle/(fat+muscle))*100)
fprintf('\nMuscle : Adipose/Soft Tissue Ratio:   %.2f : 1\n\n',muscle/fat)
if muscle/fat>3
    fprintf('The muscle:adipose/soft tissue ratio suggests that this person has an athletic, healthy build.\n')
elseif muscle/fat>1 && muscle/fat<=3
    fprintf('The muscle:adipose/soft tissue ratio suggests that this person has a healthy build.\n')
elseif muscle/fat<=1 && muscle/fat>.4
    fprintf('The muscle:adipose/soft tissue ratio suggests that this person may be overweight or deconditioned.\n')
elseif muscle/fat<=.4
    fprintf('The muscle:adipose/soft tissue ratio suggests that this person is unhealthy. They may be morbidly obese,\n')
    fprintf('severely deconditioned or ill, or have a muscular disease.\n')
end
%SHOW IMAGES
imshowpair(mri,map,'montage')
%ADDITIONAL INFO
fprintf('\n*ADDITIONAL INFO: This program is designed to run with standard-T1 weighted MRI slides, if\n')
fprintf('your MRI slide is particularly bright, dark, high- or low-contrast, you may need to adjust\n')
fprintf('the red and green parameters in the coloring loop. Area of the femur is approximated based\n')
fprintf('on the radius of the thigh, assuming that the femur has a slight ellipse shape with a\n')
fprintf('larger height than width. A montage image is shown of the original mri slide and the\n')
fprintf('colorized map from which calculations for muscle and adipose/soft tissue amount are derived side-by-side\n')
fprintf('so you can confirm that the parameters are appropriate and the calculations correct. The\n')
fprintf('area of the femur is subtracted from the area of adipose/soft tissue, since both show similar brightness.\n')
fprintf('There is an error checking mechanism in place in case there are unusual areas of brightness\n')
fprintf('outside of the thigh, outlier radius values will not affect the femur area calculation. The\n')
fprintf('usefulness of the health indicator based on muscle:adipose/soft tissue ratio is also dependent on how far down\n')
fprintf('the thigh the transverse section is obtained, since more body fat typically accumulates more\n')
fprintf('proximally toward the torso. For my parameters of athletic/healthy/deconditioned/unhealthy, I\n')
fprintf('used sections from around the midpoint between the hip and knee.\n')
fprintf('**Black areas on the map indicate areas that have the brightness of muscle tissue, but small areas of\n')
fprintf('isolated muscle ''tissue'' are likely not actual muscles, and are therefore discluded from muscle area.')