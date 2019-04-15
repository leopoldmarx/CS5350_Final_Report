% x=1, y=2, z = 3
predictOn = 3;

% 0=random 50/50, 1=middle(x), 2=middle(y), 3=middle(z), 4 =perfect split
% 5=50/50
typeOfSplit = 4;

%1,-1 to determine which side the test and train data is on. only affects
%typeOfSplit 1-4
whichHalf = 1;

%dimentions of the surface
dim = 100;

%traning kernel SquaredExponential matern32
kernel = 'matern32';

fprintf('GAUSSIAN:\n');
fprintf('Reading table...\n');
tbl = readtable('4096x1,2,1.csv');

data = table2array(tbl);
sizeData = size(data,1);

theta = 5.44;
a = sin(theta);
b = cos(theta);

trainDatainit = [];
testData = [];
if typeOfSplit == 4
    for i = 1:sizeData
        if whichHalf*(a*data(i,1)+b*data(i,2)) > 0
            trainDatainit = [trainDatainit;data(i,:)];
        else
            testData = [testData;data(i,:)];
        end
    end
elseif typeOfSplit == 0
    shuffledArray = data(randperm(sizeData),:);
    trainDatainit = shuffledArray(1:sizeData/2,:);
    testData = shuffledArray(sizeData/2:end,:);
elseif typeOfSplit == 5
    trainDatainit = data(1:sizeData/2,:);
    testData = data(sizeData/2:end,:);
else
    mid = (max(data(:,typeOfSplit)) + min(data(:,typeOfSplit)))/2;
    for i = 1:sizeData
        if whichHalf*data(i,typeOfSplit) > whichHalf*mid
            trainDatainit = [trainDatainit;data(i,:)];
        else
            testData = [testData;data(i,:)];
        end
    end
end

%normalization
[trainData,meanTrain,stdTrain] = normalize(trainDatainit);

trainData = array2table(trainData);
vars = {'x','y','z'};
trainData.Properties.VariableNames = vars;

indecies = 1:3;
indecies(predictOn) = [];
fprintf('Fitting Data...\n');
gprMdl = fitrgp(trainData,vars{predictOn},'KernelFunction',kernel);%'SquaredExponential');matern32

fprintf('Calculating Errors...\n');

%testing with training data
fprintf('\nTesting with Training data\n');
[xpredTrain,score,xint] = predict(gprMdl,trainData);
for i = 1:size(trainData,1)
    xpredTrain(i) = xpredTrain(i) * stdTrain(predictOn) + meanTrain(predictOn);
    xint(i) = xint(i) * stdTrain(predictOn) + meanTrain(predictOn);
end
%Mean Square Error
MSE = mean((xpredTrain-trainDatainit(:,predictOn)).^2);
% fprintf('MSE = %f\n',MSE);

%Root Mean Square Error
trainRMSE = sqrt(MSE);
fprintf('RMSE = %f\n',trainRMSE);

%Normalized Root Mean Square Error
% NRMSE = sqrt(mean(((xpredTrain-trainDatainit(:,predictOn))./trainDatainit(:,predictOn)).^2));
% fprintf('NRMSE = %f\n',NRMSE);

%testing with testdata
fprintf('\nTesting with test data\n');

inputData = testData(:,indecies);
count =1;
for i = indecies
    inputData(:,count) = (inputData(:,count)-meanTrain(i))/stdTrain(i);
    count = count+ 1;
end

[xpredTest,score,xint] = predict(gprMdl,inputData);

for i = 1:size(testData,1)
    xpredTest(i) = xpredTest(i) * stdTrain(predictOn) + meanTrain(predictOn);
    xint(i) = xint(i) * stdTrain(predictOn) + meanTrain(predictOn);
end

%Mean Square Error
MSE = mean((xpredTest-testData(:,predictOn)).^2);
% fprintf('MSE = %f\n',MSE);

%Root Mean Square Error
RMSE = sqrt(MSE);
fprintf('RMSE = %f\n',RMSE);

%Normalized Root Mean Square Error
% NRMSE = sqrt(mean(((xpredTest-testData(:,predictOn))./testData(:,predictOn)).^2));
% fprintf('NRMSE = %f\n',NRMSE);

figure();
rotate3d on
hold on

xlabel(vars{indecies(1)});
ylabel(vars{indecies(2)});
zlabel(vars{predictOn});

train = scatter3(trainDatainit(:,indecies(1)),trainDatainit(:,indecies(2)),xpredTrain,'.y');
test = scatter3(testData(:,indecies(1)),testData(:,indecies(2)),xpredTest,'.g');
dat = scatter3(data(:,indecies(1))',data(:,indecies(2))',data(:,predictOn),'.k');

alpha(dat, 0.7);
alpha(test,0.3);
alpha(train,0.3);

maxX = (max(data(:,1)) - meanTrain(1))/stdTrain(1);
minX = (min(data(:,1)) - meanTrain(1))/stdTrain(1);
itterX = (maxX-minX)/dim;
maxY = (max(data(:,2)) - meanTrain(2))/stdTrain(2);
minY = (min(data(:,2)) - meanTrain(2))/stdTrain(2);
itterY = (maxY-minY)/dim;
maxZ = (max(data(:,3)) - meanTrain(3))/stdTrain(3);
minZ = (min(data(:,3)) - meanTrain(3))/stdTrain(3);
itterZ = (maxZ-minZ)/dim;
itter = [itterX,itterY,itterZ];
MAX = [maxX,maxY,maxZ];
MIN = [minX,minY,minZ];

[Y,Z] = meshgrid(MIN(indecies(1)):itter(indecies(1)):MAX(indecies(1)),...
    MIN(indecies(2)):itter(indecies(2)):MAX(indecies(2)));
YZ = [Y(:), Z(:)];
pred = predict(gprMdl,YZ);
pred = pred * stdTrain(predictOn) + meanTrain(predictOn);
Y = Y*stdTrain(indecies(1)) + meanTrain(indecies(1));
Z = Z*stdTrain(indecies(2)) + meanTrain(indecies(2));
pred = vec2mat(pred,dim+1);
predSurf = surfl(Y,Z, pred');
alpha(predSurf, 0.3);
predSurf.EdgeAlpha = 0.3;

xd=linspace(MIN(1)*stdTrain(1) + meanTrain(1),MAX(1)*stdTrain(1) + meanTrain(1));
zd=linspace(MIN(3)*stdTrain(3) + meanTrain(3),MAX(3)*stdTrain(3) + meanTrain(3));
[x,z]=meshgrid(xd,zd);
y=-a*x/b;
s = surf(x,y,z);

alpha(s, 0.3);
s.EdgeAlpha = 0;

legend([{'Raw Data'},{'Test Prediction'},...
    {'Train Prediction'},{'Prediction Surface'}],...
    'Location','northeast');
view(-257,13);
hold off
title(sprintf('Surface for predicting on %c, with ideal linear split',vars{predictOn}));
str = sprintf('pred:%c,split:%g.ps',vars{predictOn},typeOfSplit);
print(gcf,'-depsc', str)

figure (2)
rotate3d on
hold on

xlabel(vars{indecies(1)});
ylabel(vars{indecies(2)});
zlabel(vars{predictOn});

predSurf = surfl(Y,Z, pred');
alpha(predSurf, 0.3);
predSurf.EdgeAlpha = 0.1;

yellow = [];
red = [];
black = [];
for i = 1:size(testData,1)
    err = abs(testData(i,predictOn)-xpredTest(i));
    if err > 0.3
        yellow = [yellow;[testData(i,indecies(1)),testData(i,indecies(2)),testData(i,predictOn)]];
    elseif err > 0.1
        red = [red;[testData(i,indecies(1)),testData(i,indecies(2)),testData(i,predictOn)]];
    else
        black = [black;[testData(i,indecies(1)),testData(i,indecies(2)),testData(i,predictOn)]];
    end
end
for i = 1:size(trainDatainit,1)
    err = abs(trainDatainit(i,predictOn)-xpredTrain(i));
    if err > 0.3
        yellow = [yellow;[trainDatainit(i,indecies(1)),trainDatainit(i,indecies(2)),trainDatainit(i,predictOn)]];
    elseif err > 0.1
        red = [red;[trainDatainit(i,indecies(1)),trainDatainit(i,indecies(2)),trainDatainit(i,predictOn)]];
    else
        black = [black;[trainDatainit(i,indecies(1)),trainDatainit(i,indecies(2)),trainDatainit(i,predictOn)]];
    end
end
scatter3(yellow(:,1),yellow(:,2),yellow(:,3),'.y');
scatter3(red(:,1),red(:,2),red(:,3),'.r');
scatter3(black(:,1),black(:,2),black(:,3),'.k');
view(-257,39);
legend([{'Surface'},{'Error > 0.3'},{'0.3 >= Error > 0.1'},{'0.1 >= Error'}],...
    'Location','northeast');
hold off
title(sprintf('Error proned arreas for predicting on %c, with ideal linear split',vars{predictOn}));
str = sprintf('error_pred:%c,split:%g.ps',vars{predictOn},typeOfSplit);
print(gcf,'-depsc', str)

