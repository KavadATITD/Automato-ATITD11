dofile("common.inc");
dofile("settings.inc");

bladeList = {"Slate Blade", "Flint Blade", "Bone Blade", "Carpentry Blade"};

function doit()
  promptParameters();
  askForWindow("Open and pin as many Wood Planes or Carpentry Shops as you want to use." ..
  "\n\nAutomatically planes boards from any number of Wood Plane or Carpentry Shop " ..
  "windows. Will repair the wood planes. Make sure to carry Slate blades!" ..
  "\n\nThe automato window must be in the TOP-RIGHT corner of the screen." ..
  "\nStand where you can reach all Wood Planes with all ingredients on you.");

  boards = 0;  --Total boards planed
  brokeplane = 0;
    if(arrangeWindows) then
      arrangeInGrid(false, false, 360, 200, nil, 60);
    end
  planeBoards(); -- Planes Boards
end

function promptParameters()
  arrangeWindows = true;
  unpinWindows = true;
  carpShop = true;
  scale = 1.1;

  local z = 0;
  local is_done = nil;
  -- Edit box and text display
  while not is_done do
    -- Make sure we don't lock up with no easy way to escape!
    checkBreak();
    local y = 5;
    lsSetCamera(0,0,lsScreenX*scale,lsScreenY*scale);

    lsPrint(10, y, 0, scale, scale, 0xd0d0d0ff, "Blade:");
    blade = lsDropdown("Blade", 90, y, 0, 180, blade, bladeList);

    if blade == 1 then
        bladeName = "Slate Blade"
    elseif blade == 2 then
        bladeName = "Flint Blade"
    elseif blade == 3 then
        bladeName = "Bone Blade"
    elseif blade == 4 then
        bladeName = "Carpentry Blade"
    end

    carpShop = readSetting("carpShop",carpShop);
    carpShop = lsCheckBox(10, 40, z, 0xFFFFFFff, "Use carpentry shop", carpShop);
    writeSetting("carpShop",carpShop);

    lsPrintWrapped(10, 60, z+10, lsScreenX - 20, 0.7, 0.7, 0xD0D0D0ff,
      "Will use Carpentry Shops instead of Wood Planes to plane boards.");

    autoOnion = readSetting("autoOnion",autoOnion);
    autoOnion = lsCheckBox(10, 100, z, 0xFFFFFFff, "Automatically eat onions", autoOnion);
    writeSetting("autoOnion",autoOnion);

    lsPrintWrapped(10, 120, z+10, lsScreenX - 20, 0.7, 0.7, 0xD0D0D0ff,
      "(Pin the 'Grilled Onion' window)\nWill automatically eat an onion, everytime the endurance buff is not visible.");

    arrangeWindows = readSetting("arrangeWindows",arrangeWindows);
    arrangeWindows = lsCheckBox(10, 180, z, 0xFFFFFFff, "Arrange windows", arrangeWindows);
    writeSetting("arrangeWindows",arrangeWindows);

    lsPrintWrapped(10, 200, z+10, lsScreenX - 20, 0.7, 0.7, 0xD0D0D0ff,
      "Will sort your pinned Wood Planes or Carpentry Shops into a grid on your screen.");

    unpinWindows = readSetting("unpinWindows",unpinWindows);
    unpinWindows = lsCheckBox(10, 240, z, 0xFFFFFFff, "Unpin windows on exit", unpinWindows);
    writeSetting("unpinWindows",unpinWindows);

    lsPrintWrapped(10, 260, z+10, lsScreenX - 20, 0.7, 0.7, 0xD0D0D0ff,
      "On exit will close all windows when you close this macro.");

    if lsButtonText(10, (lsScreenY - 30) * scale, z, 100, 0x00ff00ff, "OK") then
      is_done = 1;
    end

    if lsButtonText((lsScreenX - 100) * scale, (lsScreenY - 30) * scale, z, 100, 0xFF0000ff,
      "End script") then
      error "Clicked End Script button";
    end

    lsDoFrame();
    lsSleep(100);
  end
    if(unpinWindows) then
      setCleanupCallback(cleanup); -- unpin all open windows
    end
end

function repairBoards()
  srReadScreen();
  if not carpShop then
    clickrepair = findAllImages("boards/RepairWoodPlane.png");
    for i=1,#clickrepair do
      clickText(clickrepair[i]);
      lsSleep(100);
    end
  end
end

function planeBoards()
srReadScreen();

  while 1 do
    -- eat an onion
    if autoOnion then
      eatOnion()
    end

    clickAllImages("ThisIs.png");
    sleepWithStatus(500, "Refreshing\nBoards Planed: " .. boards);

    srReadScreen();
    local clickCount = 0;
    local ThisIsList = findAllImages("ThisIs.png");
    for i=1,#ThisIsList do
      local x = ThisIsList[i][0]-75;
      local y = ThisIsList[i][1];
      local width = 285;
      local height = 250;
      if not carpShop then
        srReadScreen();
        p = srFindImageInRange("boards/planeWood.png", x, y, width, height, 5000);
        repairBoards();
      else
        p = srFindImageInRange("boards/carpWood.png", x, y, width, height, 5000);
      end

      if(p) then
        closePopUp();
        waitForStats();
        safeClick(p[0]+10,p[1]+5);
        clickCount = clickCount + 1;
        boards = boards + 1;
        srReadScreen();
      else
        p = srFindImageInRange("boards/installBlade.png", x, y, width, height, 5000);
        if(p) then
          safeClick(p[0]+10,p[1]+5);
          lsSleep(75);
          srReadScreen();
          if bladeName == "Slate Blade" then
            p = srFindImage("boards/slateBlade.png", 5000);
          elseif bladeName == "Flint Blade" then
            p = srFindImage("boards/flintBlade.png", 5000);
          elseif bladeName == "Bone Blade" then
            p = srFindImage("boards/boneBlade.png", 5000);
          elseif bladeName == "Carpentry Blade" then
            p = srFindImage("boards/carpentryBlade.png", 5000);
          end
          if(p) then
            safeClick(p[0]+10,p[1]+5);
            lsSleep(click_delay);
          end
        end
      end
    end
  end
end

function waitForStats()
  while 1 do
    checkBreak();
    srReadScreen();
    local stats = srFindImage("stats/endurance.png");
    if stats then
      sleepWithStatus(999, "Waiting for Endurance timer to be visible and white");
    else
      break;
    end
  end
end

function cleanup()
  if(unpinWindows) then
    closeAllWindows();
  end
end

function eatOnion()
  srReadScreen();
  buffed = srFindImage("stats/enduranceBuff.png")
    if not buffed then
      srReadScreen();
      local consumeOnion = srFindImage("consume.png")
      safeClick(consumeOnion[0],consumeOnion[1]);
      waitForImage("stats/enduranceBuff.png", 5000, "Waiting for Endurance Buff icon")
    end
end

function closePopUp()
  outofwood = 0;
  while 1 do -- Perform a loop in case there are multiple pop-ups behind each other;
    checkBreak();
    srReadScreen();
    missingwood = srFindImage("boards/youdonthaveany.png");
    if(missingwood) then
      outofwood = outofwood + 1;
    end
    brokenplane = srFindImage("boards/youneedablade.png");
    if (brokenplane) then
      brokeplane = brokeplane + 1;
    end
    OK = srFindImage("OK.png");
    if OK then
      srClickMouseNoMove(OK[0],OK[1]);
      lsSleep(100);
    else
      --Check if out of supplies or out of blades
      if outofwood > 0 then
        error("Out of Wood.");
      end
      if brokeplane > 0 then
        local ThisIsList = findAllImages("ThisIs.png");
        if brokeplane >= #ThisIsList then
          error("Out of blades");
         end
      end
      break;
    end
  end
end
