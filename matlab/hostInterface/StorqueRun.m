clear all
close all

a=storqueInterface('COM6');
quit_script = 0;

figure (1)
[al bl] = init_quad_draw();

a.stream = true;

while not(quit_script)
    if (a.stream == true)
        [angles pwms] = a.get_data();
        
        
        if (~isempty(angles))
            quad_draw(angles(1),angles(2),angles(3),al,bl)
        end
        
    end

end