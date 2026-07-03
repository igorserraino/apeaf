$(document).ready(function() {

$('#ulteriori-costi-btn').on('click', function(event) {
	event.preventDefault();
    $('#ulteriori-costi-div').fadeToggle(500); // Toggle visibility
});

$('#attivitaRadio').on('change', function(event) {
	event.preventDefault();
    $('#gestori-div').show(); // Toggle visibility
});

$('#attivitagestori-select').on('change', function() {
           var selectedValue = $(this).val(); // Get the selected option's value

           // If any option other than the default is selected, remove the class
           if (selectedValue !== 'default') {
               $('#data-entry-div').removeClass('disabled');
           }
       });

});

