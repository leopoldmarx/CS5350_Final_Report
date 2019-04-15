% x=1, y=2, z = 3
predictOn = 3;

% 0=random 50/50, 1=middle(x), 2=middle(y), 3=middle(z), 4 =perfect split
% 5=50/50
typeOfSplit = 4;

%1,-1 to determine which side the test and train data is on. only affects
%typeOfSplit 1-4
whichHalf = 1;

%dimentions of the surface
dim = 25;
step = .001;

%traning kernel SquaredExponential matern32
kernel = 'matern32';

fprintf('GAUSSIAN:\n');
fprintf('Reading table...\n');
tbl = readtable('4096x1,2,1.csv');

data = table2array(tbl);
%data = data(1:2000,:);
sizeData = size(data,1);

Y = [];
Z = [];
trainrmseVal = [];
testrmseVal = [];
for theta = 0:step:2*pi
    fprintf("theta = %f\n",theta);
    a = sin(theta);
    b = cos(theta);
    Y = [Y, a];
    Z = [Z, b];
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
    %fprintf('Fitting Data...\n');
    gprMdl = fitrgp(trainData,vars{predictOn},'KernelFunction',kernel);%'SquaredExponential');matern32

    %fprintf('Calculating Errors...\n');

    %testing with training data
    %fprintf('\nTesting with Training data\n');
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
    %fprintf('RMSE = %f\n',trainRMSE);

    %Normalized Root Mean Square Error
    % NRMSE = sqrt(mean(((xpredTrain-trainDatainit(:,predictOn))./trainDatainit(:,predictOn)).^2));
    % fprintf('NRMSE = %f\n',NRMSE);

    %testing with testdata
    %fprintf('\nTesting with test data\n');

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
    %fprintf('RMSE = %f\n',RMSE);

    %Normalized Root Mean Square Error
    % NRMSE = sqrt(mean(((xpredTest-testData(:,predictOn))./testData(:,predictOn)).^2));
    % fprintf('NRMSE = %f\n',NRMSE);

    trainrmseVal = [trainrmseVal, trainRMSE];
    testrmseVal = [testrmseVal, RMSE];
end

figure();
plot(0:step:2*pi,testrmseVal);
xlabel("theta");
ylabel("test RMSE");
xlim([0 2*pi]);
ylim([0 25]);
title("Angle of seperating plane vs test RMSE");

figure();
plot(0:step:2*pi,trainrmseVal);
xlabel("theta");
ylabel("train RMSE");
title("Angle of seperating plane vs train RMSE");
min(testrmseVal)
% 
% pred = vec2mat(testrmseVal,dim+1);
% predSurf = surf(Y,Z, pred');
% 
% rotate3d on
% hold on
% 
% xlabel("a");
% ylabel("b");
% zlabel("RMSE");

