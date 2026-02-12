classdef NetworkedPairwiseExperimentPresenter < IPairwiseExperimentPresenter
    %NetworkedPairwiseExperimentPresenter for presenting pairwise
    %experiment on two monitors (computers)
    
    properties (Access = private)
        socket_a = 0;
        socket_b = 0;
    end
       
    methods
        function obj = NetworkedPairwiseExperimentPresenter(port)
            if ~exist('port', 'var') || isempty(port)
                port = 30000;
            end
            
            % most likely IP from Java. might be incorrent with multiple
            % adaptors            
            ip = char(java.net.InetAddress.getLocalHost.getHostAddress);
            fprintf('creating network server on %s:%d\n', ip, port);
            fprintf('creating socket A\n');
            obj.socket_a = tcpip('0.0.0.0', 30000, 'NetworkRole', 'server');
            obj.socket_a.OutputBufferSize  = 1024;
            fprintf('waiting for client A\n');
            fopen(obj.socket_a);
            obj.send_struct_one(obj.socket_a, struct('class', 'initialWait', 'you', 'a'));
            
            fprintf('creating socket B\n');
            obj.socket_b = tcpip('0.0.0.0', 30000, 'NetworkRole', 'server');
            obj.socket_b.OutputBufferSize  = 1024;
            fprintf('waiting for client B\n');
            fopen(obj.socket_b);
            obj.send_struct_one(obj.socket_b, struct('class', 'initialWait', 'you', 'b'));
            
            fprintf('Connections established. OK.\n');
            
            obj.send_struct_both(struct('class', 'welcome'));
            
            msg = obj.read_struct();
            assert(strcmpi(msg.class, 'ready'));
            
            obj.send_struct_both(struct('class', 'wait'));
            
           
        end
        
        function result = compare_cross_stimuli(obj, refresh_rate_a, refresh_rate_b, stimulus_a, stimulus_b, index, fix_motion, bandwidth, LUT)
            if ~exist('fix_motion', 'var') || isempty(fix_motion)
                fix_motion = false;
            end
            
            if ~exist('bandwidth', 'var') || isempty(bandwidth)
                bandwidth = 1000000000; % large enough to have no bandwidth limit
            end
            
            if ~exist('LUT', 'var') || isempty(LUT)
                LUT = [165, 165];
            end
            
            flip = round(rand());  % should we swap "a" and "b"?
            if flip
                [refresh_rate_a, refresh_rate_b] = swap(refresh_rate_a, refresh_rate_b);
                [stimulus_a, stimulus_b] = swap(stimulus_a, stimulus_b);
            end
            
            stimulus_a.motion = stimulus_a.motion.randomise();
            if fix_motion
                stimulus_b.motion = stimulus_a.motion;
            else
                stimulus_b.motion = stimulus_b.motion.randomise();
            end
            msg_a = struct('class', 'disp', 'refresh_rate', refresh_rate_a, 'stimulus', stimulus_a.serialiseToNode(), 'bandwidth', bandwidth, 'LUT', LUT);
            msg_b = struct('class', 'disp', 'refresh_rate', refresh_rate_b, 'stimulus', stimulus_b.serialiseToNode(), 'bandwidth', bandwidth, 'LUT', LUT);
            obj.send_struct_one(obj.socket_a, msg_a);
            obj.send_struct_one(obj.socket_b, msg_b);
            
            obj.send_struct_both(struct('class', 'start'));
            
            selection_made = false;
            while ~selection_made
                msg_in = obj.read_struct();
                selection_made = strcmpi(msg_in.class, 'picked');
                if strcmpi(msg_in.class, 'cancel')
                    result = -1;
                    return;
                end
                obj.send_struct_both(struct('class', 'start'));
            end

            obj.send_struct_both(struct('class', 'wait', 'msg', sprintf('Trial %d', index)));         
            result = msg_in.pick;
            if flip
                result = 1 - result;
            end
        end
        
        function obj = experiment_finished(obj, force_kill)
            if force_kill
               obj.send_struct_both(struct('class', 'die'));
            else
                obj.send_struct_both(struct('class', 'thanks'));
            end
            
            fclose(obj.socket_a);
            fclose(obj.socket_b);
        end
    end 
    
    
    methods (Access = private)
        
        function send_struct_one(obj, socket, data)
            % send a data packet with the provided struct (data) to one
            % client
            payloadStr = jsonencode(data);
            packet_size = length(payloadStr);
            fwrite(socket, packet_size, 'uint32');   
            fwrite(socket, payloadStr, 'uint8');
        end
        
        function send_struct_both(obj, data)
            % send a data packet with the provided struct (data) to both
            % clients
            payloadStr = jsonencode(data);
            packet_size = length(payloadStr);
            fwrite(obj.socket_a, packet_size, 'uint32');   
            fwrite(obj.socket_b, packet_size, 'uint32');
            fwrite(obj.socket_a, payloadStr, 'uint8');
            fwrite(obj.socket_b, payloadStr, 'uint8');
        end
        
        function data = read_struct(obj)
            % read packet from the primary (A) computer
            % returns a struct
            
            while (obj.socket_a.BytesAvailable < 4)
                % wait for 4 bytes (packet size)
                pause( 0.5 );              
            end
            
            packet_size = fread(obj.socket_a, 1, 'uint32');
            while (obj.socket_a.BytesAvailable < packet_size)
                % wait for data 
                pause( 0.5 );              
            end
            payload = fread(obj.socket_a, packet_size, 'uint8');
            payloadStr = char(payload)';
            
            data = jsondecode(payloadStr);
        end
    end
end

function [b, a] = swap(a, b)
end
