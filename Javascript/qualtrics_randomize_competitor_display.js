//John Spaw
//Code to construct survey flow logic based on awareness of Planet Fitness competitors

	//////// PROCESS OVERVIEW ////////

	//// IN QUALTRICS
	// 1. Create embedded data fields for display flags (one per competitor) at start of survey in Qualtrics (default as NA)
	// 2. Create javascript call in qualtrics - !! Must be in a separate block after awareness question and before competitor randomization !!
		// Javascript process is outlined in section below
	// 3. Make separate question batteries for each competitor - set display logic using the embedded data fields from the JS 
		// (1 = display, 0 = don't display)

	//// IN JAVASCRIPT call
		// I. 	Read in responses from a competitor/market awareness question
		// II. 	Build awareness flags for each competitor based on available responses
		// III. Construct an awareness set (an array of competitors that the respondent is aware of) based on flags
		// IV. 	Randomly select one competitor from the awareness set
		// V. 	Create logical (in this case 0/1 integer) flags for whether or not to display a given competitor - default all at 0
		// VI. 	Set selected competitor display flag to 1
		// VII. Output display flags as embedded data to qualtrics using API 



//All code needs to be wrapped in this addOnload function in order to load correctly 
Qualtrics.SurveyEngine.addOnload(function(){

//Prototype function to select a random element from an array - used to select competitor from awareness set 
Array.prototype.randomElement = function () {
    return this[Math.floor(Math.random() * this.length)];
};

//Load responses from matrix question... each variable gives a row (gym) level selection
	// !!! NOTE - you will need up change both the variable name AND the QID (this can be determined using Qualtrics piped text)
var planetfitness_response = "${q://QID1451/ChoiceGroup/SelectedAnswers/1}";
var anytimefitness_response = "${q://QID1451/ChoiceGroup/SelectedAnswers/2}";
var blink_response = "${q://QID1451/ChoiceGroup/SelectedAnswers/3}";
var crunch_response = "${q://QID1451/ChoiceGroup/SelectedAnswers/4}";
var retro_response = "${q://QID1451/ChoiceGroup/SelectedAnswers/5}";
var workoutanytime_response = "${q://QID1451/ChoiceGroup/SelectedAnswers/6}";
var youfit_response = "${q://QID1451/ChoiceGroup/SelectedAnswers/7}";


//Set awareness logical flags for each competitor
var heard_not_member = "I have heard of this gym, but am not a member";
var heard_member = "I am currently a member of this gym";

var planetfitness_aware = (planetfitness_response == heard_not_member || planetfitness_response == heard_member);
var anytimefitness_aware = (anytimefitness_response == heard_not_member || anytimefitness_response == heard_member);
var blink_aware = (blink_response == heard_not_member || blink_response == heard_member);
var crunch_aware = (crunch_response == heard_not_member || crunch_response == heard_member);
var retro_aware = (retro_response == heard_not_member || retro_response == heard_member);
var workoutanytime_aware = (workoutanytime_response == heard_not_member || workoutanytime_response == heard_member);
var youfit_aware = (youfit_response == heard_not_member || youfit_response == heard_member);



//Create array for awareness set - if aware of competitor then push to array
//Planetfitness does not get added to the awareness set for random selection since we always want it displayed 
var awareness_set = [];
if (anytimefitness_aware) {awareness_set.push("Anytime Fitness")};
if (blink_aware) {awareness_set.push("Blink")};
if (crunch_aware) {awareness_set.push("Crunch")};
if (retro_aware) {awareness_set.push("Retro")};
if (workoutanytime_aware) {awareness_set.push("Workout Anytime")};
if (youfit_aware) {awareness_set.push("YouFit")};


// Randomly select one competitor from awareness set 
if (!(awareness_set === undefined || awareness_set.length == 0)) {
    var competitor_choice = awareness_set.randomElement()
};

//For troubleshooting - check Javascript console using Command + Option + J to view 
console.log(competitor_choice)



//Create flags to display competitor questions - default question display flags as 0 (false)
var planetfitness_display = 0;
var anytimefitness_display = 0;
var blink_display = 0;
var crunch_display = 0;
var retro_display = 0;
var workoutanytime_display = 0;
var youfit_display = 0;

// If the competitor was randomly selected from awareness set, flip its display flag to 1 (true)
	//Planetfitness is automatically flipped on if respondent is aware
if (planetfitness_aware) {planetfitness_display = 1};
if (competitor_choice == "Anytime Fitness") {anytimefitness_display = 1};
if (competitor_choice == "Blink") {blink_display = 1};
if (competitor_choice == "Crunch") {crunch_display = 1};
if (competitor_choice == "Retro") {retro_display = 1};
if (competitor_choice == "Workout Anytime") {workoutanytime_display = 1};
if (competitor_choice == "YouFit") {youfit_display = 1};



//Set embedded data for display flags in qualtrics using API 
Qualtrics.SurveyEngine.setEmbeddedData("planetfitness_display", planetfitness_display);
Qualtrics.SurveyEngine.setEmbeddedData("anytimefitness_display", anytimefitness_display);
Qualtrics.SurveyEngine.setEmbeddedData("blink_display", blink_display);
Qualtrics.SurveyEngine.setEmbeddedData("crunch_display", crunch_display);
Qualtrics.SurveyEngine.setEmbeddedData("retro_display", retro_display);
Qualtrics.SurveyEngine.setEmbeddedData("workoutanytime_display", workoutanytime_display);
Qualtrics.SurveyEngine.setEmbeddedData("youfit_display", youfit_display);


});