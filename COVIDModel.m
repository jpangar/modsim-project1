classdef COVIDModel < handle
    %MAIN SEIRVD Model with ONLY two interacting subpopulations

    properties
        subpopulation1
        subpopulation2
        
        PInfect1Contact2
        PInfect2Contact1
        
    end

    methods
        function obj = COVIDModel(subpopulation1,subpopulation2, PInfect1Contact2, PInfect2Contact1)
            %Provide both subpopulations and parameters indicating how 
            %   Detailed explanation goes here
            obj.subpopulation1 = subpopulation1;
            obj.subpopulation2 = subpopulation2;
            obj.PInfect1Contact2 = PInfect1Contact2;
            obj.PInfect2Contact1 = PInfect2Contact1;

        end
        
        function n = getPopulation(obj)
            n = obj.subpopulation1.getPopulation() + obj.subpopulation2.getPopulation();
        end

        function simulateAction(obj, time)
            % use fraction so numbers don't explode
            subpopulation1Infectious = obj.subpopulation1.numInfectious / obj.subpopulation1.getLiving();
            subpopulation2Infectious = obj.subpopulation2.numInfectious / obj.subpopulation2.getLiving();

            totalInfectious1 = (1-obj.PInfect2Contact1)*subpopulation1Infectious + obj.PInfect2Contact1*subpopulation2Infectious;
            totalInfectious2 = (1-obj.PInfect1Contact2)*subpopulation2Infectious + obj.PInfect1Contact2*subpopulation1Infectious;
            
            obj.subpopulation1.simulateAction(time, totalInfectious1);
            obj.subpopulation2.simulateAction(time, totalInfectious2);
        end
    end
end