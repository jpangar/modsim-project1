classdef Subpopulation < handle
    %Subpopulation class
    % Parameters MUST be in range [0,1]
    % CURRENT LIMITATIONS:
    % Does not account that there are a limited amount of vaccines
    
    properties
        Pcontact
        Pinfectivity_semirisk
        Pinfectivity_risk
        Precovered
        Pdeceased
        Pvaccinated

        numPostInfection
        numVaccinated
        numNaive
        numInfectious
        numDeceased
        
        newCases = 0
        newDeaths = 0
    end

    methods
        function obj = Subpopulation(Pcontact, Pinfectivity_semirisk, Pinfectivity_risk, ...
                                     Precovered, Pdeceased, Pvaccinated, ...
                                     numPostInfection, numVaccinated, numNaive, ...
                                     numInfectious, numDeceased)
            %Subpopulation Construct an instance of this class using
            %parameters
            %   Enter parameters in correct order, initial amount of
            %   deceased and
            assert(Pinfectivity_semirisk <= Pinfectivity_risk, "Vaccinated/post-infected people cannot be more infectious than infection-naive");
            assert(Pcontact + Pvaccinated <= 1, "Flow exceeds stock quantity");
            assert(Precovered + Pdeceased <= 1, "Flow exceeds stock quantity");
            obj.Pcontact = Pcontact;
            obj.Pinfectivity_semirisk = Pinfectivity_semirisk;
            obj.Pinfectivity_risk = Pinfectivity_risk;
            obj.Precovered = Precovered;
            obj.Pdeceased = Pdeceased;
            obj.Pvaccinated = Pvaccinated;

            obj.numPostInfection = numPostInfection;
            obj.numVaccinated = numVaccinated;
            obj.numNaive = numNaive;
            obj.numInfectious = numInfectious;
            obj.numDeceased = numDeceased;
        end
    
        function n = getLiving(obj)
            n = obj.numPostInfection + obj.numVaccinated + obj.numNaive + obj.numInfectious;
        end

        function n = getPopulation(obj)
            n = obj.getLiving() + obj.numDeceased;
        end

        function simulateAction(obj, time, infectiousFraction)
            %METHOD1 Iterate through one timestep using object parameters
            %and stocks
            %   Uses equations accordingly. No return value           
         

            vaccinatedContact = obj.Pcontact * obj.numVaccinated;
            postInfectionContact = obj.Pcontact * obj.numPostInfection;

            naiveContact = obj.Pcontact * obj.numNaive;

            deltaInfectiousVaccine = vaccinatedContact*obj.Pinfectivity_semirisk*infectiousFraction;
            deltaInfectiousPostInfection = postInfectionContact*obj.Pinfectivity_semirisk*infectiousFraction;

            deltaInfectiousNaive = naiveContact*obj.Pinfectivity_risk*infectiousFraction;

            deltaRecovered = obj.Precovered * obj.numInfectious;
            deltaDeceased = obj.Pdeceased * obj.numInfectious;

            deltaVaccinePostInfection = obj.Pvaccinated*obj.numPostInfection;
            deltaVaccineNaive = obj.Pvaccinated*obj.numNaive;
            
            % Must clamp when delta calculated by 3 or more variables;

            %   Makes Vaccination only occur after time = 365 instead of
            %   10. Though 10 is written, this is variable across every
            %   vaccinated person (e.g., we need to keep track of everyone
            %   who is vaccinated and when their 10 days has started,
            %   which we can do in final draft

            if (time < 10) 
              deltaVaccinePostInfection = 0;
              deltaVaccineNaive = 0;
            end
            
            obj.numNaive = obj.numNaive - deltaVaccineNaive - deltaInfectiousNaive;
            obj.numPostInfection = obj.numPostInfection + deltaRecovered - deltaVaccinePostInfection - deltaInfectiousPostInfection;
            obj.numVaccinated = obj.numVaccinated + deltaVaccinePostInfection + deltaVaccineNaive - deltaInfectiousVaccine;
            obj.numDeceased = obj.numDeceased + deltaDeceased;
            obj.numInfectious = obj.numInfectious + deltaInfectiousPostInfection + deltaInfectiousVaccine + deltaInfectiousNaive - deltaDeceased - deltaRecovered;
            obj.newCases = deltaInfectiousNaive + deltaInfectiousVaccine + deltaInfectiousPostInfection;
            obj.newDeaths = deltaDeceased;
        end

    end
end