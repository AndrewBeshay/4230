function video_feed()
    
    warning('off', 'images:initSize:adjustingMag');

    %% Table Camera

    TabCam = videoinput('winvideo', 1, 'MJPG_1600x1200');
    TabCamRes = TabCam.VideoResolution;
    TabCamBands = TabCam.NumberOfBands;
    TabCamImg = imshow(zeros([TabCamRes(2), TabCamRes(1), TabCamBands]), 'Parent', "?");
    TabCamPrev = preview(TabCam,TabCamImg);
    src1 = getselectedsource(TabCam);
    src1.ExposureMode = 'manual';
    src1.Exposure = -4;
    cam1_capture_func = @(~,~)capture_image(TabCam,'table_img');
    TabCamPrev.ButtonDownFcn = cam1_capture_func;
    fig1.KeyPressFcn = cam1_capture_func;


    %% Conveyor Camera
    
    ConvCam = videoinput('winvideo', 2, 'MJPG_1600x1200');
    ConvCamRes = ConvCam.VideoResolution;
    ConvCamBands = ConvCam.NumberOfBands;
    ConvCamImg = imshow(zeros([ConvCamRes(2), ConvCamRes(1), ConvCamBands]), 'Parent', axe2);
    prev2 = preview(ConvCam,ConvCamImg);
    src2 = getselectedsource(ConvCam);
    src2.ExposureMode = 'manual';    
    src2.Exposure = -4;
    cam2_capture_func = @(~,~)capture_image(ConvCam,'conveyor_img');
    fig2.KeyPressFcn = cam2_capture_func;
    prev2.ButtonDownFcn = cam2_capture_func;

    function capture_image (vid, name)
        snapshot = getsnapshot(vid);
        imwrite(snapshot, [name, datestr(datetime('now'),'_mm_dd_HH_MM_SS'), '.jpg']);
        disp([name 'captured']);
    end


end