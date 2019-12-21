% Interface for querying a database
%
% Code adapted from:
% Covert Lab, Department of Bioengineering, Stanford University
classdef Database < handle
    properties (Abstract = true, SetAccess = protected)
        pathToDB
    end

    methods
        function this = Database(varargin)
            switch nargin 
                case 1
                    this.pathToDB = varargin{1};
                case 4
                    this.pathToDB = varargin{1};
                otherwise
                    throw(MException('Database:error', 'invalid options'));
            end                       
        end
    end

    methods (Abstract = true)
        result = query(this)
    end    
end