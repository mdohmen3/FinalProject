function [] = bowlingScore()
    close all
    global gui;
    global frameCounter; %Keeps track of which subframe we are in (1-21)
    global currentScore; %The current score- updated throughout the game
    global frameScore; %The score for each frame- resets after the end of each frame (used to calculate scores)
    frameScore = 0;
    frameCounter = 1; %We need to start at frame one
    currentScore = 0; %Start with a score of zero
    gui.fig = figure(); %creates a figure
    gui.frames = {}; %The individual frames
    gui.frames{21} = uicontrol('style', 'pushbutton', 'units', 'normalized', 'position', [0.8895 .8 .04 .075], 'string', ' ', 'FontSize', 17); %Added for the third shot in the 10th frame
    gui.frameNum = {}; %The numbers above the frames
    gui.scoreDisp = {}; %The display of the score under each frame
    gui.scoreInput = {}; %The number pad which allows you to input scores
    gui.reset = uicontrol('style', 'pushbutton', 'units', 'normalized', 'position', [0.1 0.1 0.1 .08], 'string', 'Reset', 'FontSize', 16, 'callback', {@reset});
    for i = 1:2:19
        gui.frames{i} = uicontrol('style', 'pushbutton', 'units', 'normalized', 'position', [0.05+0.0855*(i/2-.5) .8 .04 .075], 'string', ' ', 'FontSize', 17); %Creates the first half of every frame
    end
    for i = 2:2:20
        gui.frames{i} = uicontrol('style', 'pushbutton', 'units', 'normalized', 'position', [0.0855+0.0855*(i/2-1) .8 .04 .075], 'string', ' ', 'FontSize', 17); %Creates the second half of every frame
    end
    for i = 1:10
        gui.frameNum{i} = uicontrol('style','text', 'units', 'normalized', 'position', [0.06775+0.0855*(i-1) .88 .04 .055], 'string', i, 'FontSize', 17); %Creates the numbers above each frame
        gui.scoreDisp{i} = uicontrol('style', 'pushbutton', 'units', 'normalized', 'position', [0.05+0.0855*(i-1) .73 .08 .075], 'string', ' ', 'FontSize', 17); %Creates the display for the score under each frame
    end
    
    for i = 1:3
        for j = 1:4
            gui.scoreInput{i,j} = uicontrol('style', 'pushbutton', 'units', 'normalized', 'position', [0.3+(0.4/3)*(i-1) (8/15)-(0.4/3)*(j-1) .125 .132], 'string', 3*(3-j)+i, 'FontSize', 20, 'callback', {@scoreDisp}); %creates the score input, and puts numbers in for 1-9
        end
    end
    gui.scoreInput{1,4}.String = '/'; 
    gui.scoreInput{2,4}.String = '-';
    gui.scoreInput{3,4}.String = 'X'; %These three make the strike, spare, and miss buttons to keep score- they override the bottom three buttons made in line 30
end

function [] = scoreDisp(source, event) %Displays the inputs for each frame
    global justReset;
    justReset = 0; %Make justReset false every time we input a number so that it never skips over the frameCounter = frameCounter + 1 on line 73
    global gui;
    global frameCounter;
    if frameCounter < 20 %These are the rules for the first 9 frames and the first ball of the 10th
        if floor(frameCounter / 2) ~= frameCounter / 2 && source.String == '/' %Doesn't allow for a spare on the first ball of a frame
            msgbox('Error! Please enter the correct score. Press X for a strike','Scoring Error', 'error', 'modal')
        elseif floor(frameCounter / 2) == frameCounter / 2 && (source.String == 'X' || (str2double(gui.frames{frameCounter - 1}.String) + str2double(source.String)) > 9) %Doesn't allow for a strike on the second ball, or for an input of 10 or greater
            msgbox('Error! Please enter correct score. Press / for a spare.', 'Scoring Error', 'error', 'modal')
        elseif source.String == 'X' && frameCounter ~= 19 %What to do if you get a strike in any frame except the tenth.
            frameCounter = frameCounter + 1; %Moves to the second half of that frame so the strike will be put in the right spot
            gui.frames{frameCounter}.String = source.String; %Inserts the 'X'
            scoreKeep(source, event); %Runs scoreKeep on that frame
            frameCounter = frameCounter + 1; %Moves to the first ball of the next frame
        else
            gui.frames{frameCounter}.String = source.String; %Updates how many pins you got in that shot
            scoreKeep(source, event); %Runs scoreKeep to update the score
            frameCounter = frameCounter + 1; %Advances to the next ball
        end
    elseif frameCounter > 19 %Rules for the 10th frame
        if frameCounter == 20 && gui.frames{19}.String ~= 'X' && source.String == 'X' %Doesn't allow for a strike after a non-strike
            msgbox('Error! Please enter correct score. Press / for a spare.', 'Scoring Error', 'error', 'modal')
        elseif frameCounter == 21 && gui.frames{20}.String ~= 'X' && gui.frames{20}.String ~= '/' && source.String == 'X' %Doesn't allow for a stike after something other than a strike or spare
            msgbox('Error! Please enter correct score. Press / for a spare.', 'Scoring Error', 'error', 'modal') %Doesn't allow for an input of 10 or greater in any 2 consecutive sub-frames.
        elseif str2double(gui.frames{frameCounter - 1}.String) + str2double(source.String) > 9 %Doesn't allow for a total of more than 9 in two consecutive shots.
            msgbox('Error! Please enter correct score. Press / for a spare.', 'Scoring Error', 'error', 'modal')
        elseif frameCounter == 21 && (gui.frames{20}.String == 'X' || gui.frames{20}.String == '/') && source.String == '/' %Doesn't allow for a spare after a strike or a spare in subframe 21
            msgbox('Error! Please enter the correct score. Press X for a strike', 'Scoring Error', 'error', 'modal')
        elseif frameCounter == 20 && gui.frames{19}.String == 'X' && source.String == '/' %Doesn't allow for a spare after a strike in subframe 20
            msgbox('Error! Please enter the correct score. Press X for a strike', 'Scoring Error', 'error', 'modal')
        else
            gui.frames{frameCounter}.String = source.String; %Updates how many pins you got in that shot  
            scoreKeep(source, event); %Runs scoreKeepTenth to update the score 
            if justReset == 0 %Only advances the frameCounter if justReset == 0
            frameCounter = frameCounter + 1; %Only ever go foreward one sub-frame in the 10th
            end
        end
    end
end

function [] = scoreKeep(source, event) %The function that calculates frameScore and then calls checkMark on that frameScore
global frameCounter;
global frameScore;
    if frameCounter < 19 && mod(frameCounter,2) == 1    %What to do if it's the first shot of a frame (Doesn't include strikes because those are placed...
                                                        %in the second half of each frame)
        if source.String == '-'     %Need to tell the system that a '-' means you got zero
            frameScore = 0;
        else
            frameScore = str2double(source.String);     %The only other options for the first half of the frame is 1-9, so update the current frame score to correspond
        end
        checkMark(source, frameScore);  %Checks for a mark (strike or spare) in the previous frame(s)
    elseif frameCounter < 19 && mod(frameCounter,2) == 0    %Looks at the second ball of each frame (other than the 10th)
        if source.String == '-'
            frameScore = frameScore + 0;    %If you got nothing, just keep frameScore the same (I know this isn't necessary to have here- it does nothing)
        elseif source.String ~= 'X' && source.String ~= '/'
            frameScore = frameScore + str2double(source.String);    %if you got anything other than a strike or spare, just add that to your first ball score
        else
            frameScore = 10; %If you got a strike or spare, your score for that frame is 10.
        end
        checkMark(source, frameScore); %Checks for a mark for the previous frame
    elseif frameCounter == 19 %Different rules for the 10th frame
        if source.String == '-' 
            frameScore = 0;
        elseif source.String == 'X'
            frameScore = 10;
        else
            frameScore = str2double(source.String); %Only three options: zero, strike, or a number 1-9. 
                                %We need to update the frameScore, but we don't need to do anything else
        end
        checkMark(source, frameScore); %Runs checkMark on the first ball of the tenth
    elseif frameCounter == 20
        if source.String == '-'
            frameScore = frameScore + 0; %Not really needed, but just here to see that we don't add anything on a miss
        elseif source.String == 'X' %Only way this is possible is if the first two shots are strikes, so make frameScore 20
            frameScore = 20; 
        elseif source.String == '/' %Automatically have a frameScore of 10 if the second shot is a spare
            frameScore = 10;
        else
            frameScore = frameScore + str2double(source.String); %The only other option is to add that shot to frameScore
        end
        checkMark(source,frameScore); %Runs checkMark on the second shot
    elseif frameCounter == 21
        if source.String == '-'
            frameScore = frameScore + 0;
        elseif source.String == 'X' 
            frameScore = frameScore + 10;
        elseif source.String == '/' %Only way is to have strike, 1-9, spare which gives a frameScore of 20
            frameScore = 20;
        else
            frameScore = frameScore + str2double(source.String);
        end
        checkMark(source, frameScore); %Runs checkMark on the last ball- doesn't really check for a mark just runs the end of game command
    end 
end

function [] = checkMark(source, n) %Checks for strikes and spares in the previous frame(s)- updates currentScore and scoreDisp if necessary
    global gui;
    global frameCounter;
    global currentScore;
    if frameCounter < 3 %Have to have different rules for the first frame because there is no previous frame to look back at for a mark (strike/spare)
        if mod(frameCounter,2) == 1 %If it's the first ball of the game, you don't need to do anything
            return;
        elseif gui.frames{frameCounter}.String == '/' %checks to see if the frameScore was 10 for that frame (meaning a strike/spare)
            currentScore = 10; %If so, start off the game with a score of 10, but don't display that score yet until we know how many pins are knocked over in the next shot(s).
        elseif gui.frames{frameCounter}.String == 'X'
            return;
        else
            currentScore = n; %Set the current score to whatever that first frame score was
            gui.scoreDisp{1}.String = currentScore; %Display that under that frame, since it wasn't a strike or spare
        end
    elseif frameCounter > 2 && frameCounter < 19 %Same rules (mostly) for frames 2 through 9
        if mod(frameCounter,2) == 1 %Looking at the first ball of every frame
            if gui.frames{frameCounter - 1}.String == '/' %Checks to see if the last ball was a spare
                currentScore = currentScore + n; %Add 'n,' because the score of the first ball needs to be added to the frame before 
                gui.scoreDisp{(frameCounter-1)/2}.String = currentScore; %Now the score for the last frame can be displayed
            elseif gui.frames{frameCounter - 1}.String == 'X' && frameCounter > 4 && gui.frames{frameCounter - 3}.String == 'X' %Checks to see when this shot is not a strike, but the last two shots...
                                                                                                                                %were both strikes. Cannot happen in the second frame though because... 
                                                                                                                                %there's no -1st frame
                currentScore = currentScore + n; %If the last two shots were strike, add the score in that shot to the current score
                gui.scoreDisp{(frameCounter - 1) / 2 - 1}.String = currentScore; %Update the score underneath the frame 2 frames ago (since that score can no longer change)
            else
                return;
            end
        elseif mod(frameCounter,2) == 0 %Looking at the second half of each frame
            if gui.frames{frameCounter - 2}.String ~= 'X' && gui.frames{frameCounter}.String ~= 'X' %Looking at the case where there wasn't a strike this frame nor last.
                if n == 10 %If it was a spare
                    currentScore = currentScore + n; %Just add the 10 points, but don't update the score under that frame
                else
                currentScore = currentScore + n; 
                gui.scoreDisp{frameCounter / 2}.String = currentScore; %Updates the score under that frame since it isn't dependent on the next throw (not a strike/spare)
                end
            elseif gui.frames{frameCounter - 2}.String == '/' && gui.frames{frameCounter}.String == 'X' %If a strike follows a spare
                currentScore = currentScore + 10; 
                gui.scoreDisp{frameCounter / 2 - 1}.String = currentScore; %Update the score under the previous frame
            elseif gui.frames{frameCounter}.String ~= 'X' && gui.frames{frameCounter - 2}.String == 'X' %If the previous frame was a strike but this one isn't
                currentScore = currentScore + 10 + n; %Add the amount of points received that frame plus 10 for the strike
                gui.scoreDisp{frameCounter / 2 - 1}.String = currentScore; %Update the score under the previous frame
                currentScore = currentScore + n; %Add another 'n' points for that frame
                if n == 10 %If it was a spare, don't display
                    return;
                else
                    gui.scoreDisp{frameCounter / 2}.String = currentScore; %If it was anything other than a spare, display the score under that frame
                end 
            elseif gui.frames{frameCounter}.String == 'X' && gui.frames{frameCounter - 2}.String ~= 'X' %If a strike follows anything other than another strike (spare has already been taken care of above)
                return; %Don't need to do anything - points for strike added after next shots 
            else %The only thing left is 2+ strikes in a row
                if frameCounter > 4 && gui.frames{frameCounter - 4}.String == 'X' %If it's past the 2nd frame and you get three strikes in a row
                    currentScore = currentScore + 10; %Add 10 for the additional strike
                    gui.scoreDisp{frameCounter / 2 - 2}.String = currentScore; %Display the score
                    currentScore = currentScore + 20; %Add another 20 for the 2 strikes
                elseif frameCounter > 2 && gui.frames{frameCounter - 2}.String == 'X' %If it's past the 1st frame and you only have two strikes in a row
                    currentScore = currentScore + 20; %Add 20 to the current Score
                end
                
            end            
        end
    elseif frameCounter == 19 %Different rules for the 10th frame
        if gui.frames{frameCounter}.String == 'X' %Look at cases where the first shot in the 10th is a strike
            if gui.frames{frameCounter - 3}.String == 'X' && gui.frames{frameCounter - 1}.String == 'X' %If the last two shots were strikes
                currentScore = currentScore + 10; %Add 10 before updating the score
                gui.scoreDisp{(frameCounter - 1) / 2 - 1}.String = currentScore; %Updates score for 8th frame
            elseif gui.frames{frameCounter - 1}.String == '/' %Looks at when there was a spare in the 9th
                currentScore = currentScore + 10; 
                gui.scoreDisp{(frameCounter - 1) / 2}.String = currentScore; %Updates score for the 9th
            else
                return; %Don't need to do anything yet if neither of the above cases are true
            end
        else
            if gui.frames{frameCounter - 3}.String == 'X' && gui.frames{frameCounter - 1}.String == 'X' 
                currentScore = currentScore + n; %Add 'n' if the last two shots were strikes
                gui.scoreDisp{(frameCounter - 1) / 2 - 1}.String = currentScore; %Updates the 8th frame score
            elseif gui.frames{frameCounter - 1}.String == '/' 
                currentScore = currentScore + n; %Adds 'n' if the last shot was a spare
                gui.scoreDisp{(frameCounter - 1) / 2}.String = currentScore; %Updates the 9th frame score
            else
                return; %Don't need to do anything if neither of those cases are true
            end
        end
    elseif frameCounter == 20 %Rules for the second shot in the tenth
        if gui.frames{frameCounter - 2}.String == 'X' %If the shot in the 9th was a strike
            currentScore = currentScore + 10 + n; %Adds the current 10th and 10 for the strike frame score to the currentScore
            gui.scoreDisp{(frameCounter / 2) - 1}.String = currentScore; %Updates the 9th frame score
        end
        if gui.frames{frameCounter}.String ~= 'X' && gui.frames{frameCounter}.String ~= '/' && gui.frames{frameCounter - 1}.String ~= 'X' %If the game is over- no strikes or spares in the 10th
            currentScore = currentScore + n; %Adds the tenth frame score to currentScore
            gui.scoreDisp{frameCounter / 2}.String = currentScore; %Displays score
            dlgText = sprintf('Your Score Is: %d\nWould You Like to Play Again?', currentScore); %string to put in the dialogue box
            answer = questdlg(dlgText, 'End Of Game', 'New Game', 'Quit', 'New Game'); %Creates dialogue box
            endOfGame(answer); %Run a function to perform certain actions depending on which they chose
        end
    elseif frameCounter == 21
        currentScore = currentScore + n; %Game is over- same things as lines 223-227
        gui.scoreDisp{(frameCounter - 1) / 2}.String = currentScore; 
        dlgText = sprintf('Your Score Is: %d\nWould You Like to Play Again?', currentScore); 
        answer = questdlg(dlgText, 'End Of Game', 'New Game', 'Quit', 'New Game');
        endOfGame(answer);
    end

        
end

function [] = endOfGame(answer)
global justReset;
    if strcmp(answer, 'New Game')
        bowlingScore(); %Run the original function
        justReset = 1;  %The way the scoreDisp function works, it adds 1 to the
                        %frameCounter after it runs scoreKeep and checkMark.
                        %This variable prevents it from adding 1 to frameCounter after
                        %the reset. See line 72.
    else
        close all; %If they chose anything other than 'New Game', just close out the GUI.
    end
end

function [] = reset(~,~)
    close all
    global gui;
    global frameCounter; %Keeps track of which subframe we are in (1-21)
    global currentScore; %The current score- updated throughout the game
    global frameScore; %The score for each frame- resets after the end of each frame (used to calculate scores)
    frameScore = 0;
    frameCounter = 1; %We need to start at frame one
    disp(frameCounter);
    currentScore = 0; %Start with a score of zero
    gui.fig = figure();
    gui.frames = {};
    gui.frames{21} = uicontrol('style', 'pushbutton', 'units', 'normalized', 'position', [0.8895 .8 .04 .075], 'string', ' ', 'FontSize', 17); %Added for the third shot in the 10th frame
    gui.frameNum = {};
    gui.scoreDisp = {};
    gui.scoreInput = {};
    gui.reset = uicontrol('style', 'pushbutton', 'units', 'normalized', 'position', [0.1 0.1 0.1 .08], 'string', 'Reset', 'FontSize', 16, 'callback', {@reset});
    for i = 1:2:19
        gui.frames{i} = uicontrol('style', 'pushbutton', 'units', 'normalized', 'position', [0.05+0.0855*(i/2-.5) .8 .04 .075], 'string', ' ', 'FontSize', 17); %Creates the first half of every frame
    end
    for i = 2:2:20
        gui.frames{i} = uicontrol('style', 'pushbutton', 'units', 'normalized', 'position', [0.0855+0.0855*(i/2-1) .8 .04 .075], 'string', ' ', 'FontSize', 17); %Creates the second half of every frame
    end
    for i = 1:10
        gui.frameNum{i} = uicontrol('style','text', 'units', 'normalized', 'position', [0.06775+0.0855*(i-1) .88 .04 .055], 'string', i, 'FontSize', 17); %Creates the numbers above each frame
        gui.scoreDisp{i} = uicontrol('style', 'pushbutton', 'units', 'normalized', 'position', [0.05+0.0855*(i-1) .73 .08 .075], 'string', ' ', 'FontSize', 17); %Creates the display for the score under each frame
    end
    
    for i = 1:3
        for j = 1:4
            gui.scoreInput{i,j} = uicontrol('style', 'pushbutton', 'units', 'normalized', 'position', [0.3+(0.4/3)*(i-1) (8/15)-(0.4/3)*(j-1) .125 .132], 'string', 3*(3-j)+i, 'FontSize', 20, 'callback', {@scoreDisp}); %creates the score input, and puts numbers in for 1-9
        end
    end
    gui.scoreInput{1,4}.String = '/'; 
    gui.scoreInput{2,4}.String = '-';
    gui.scoreInput{3,4}.String = 'X'; %These three make the strike, spare, and miss buttons to keep score
end
