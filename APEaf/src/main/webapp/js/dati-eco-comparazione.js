$(document).ready(function() {

	$('#attivitagestori-select').on('change', function() {
	    $('#type').val('0');
	    $('#comparazione-form').submit();
	});

});


(function() {

    function syncAttivitaGestori() {
        var select = document.getElementById("attivitagestori-select");
        var hidden = document.getElementById("id-attivitagestori");

        if (!select || !hidden) {
            return;
        }

        hidden.value = select.value || "";
    }

    document.addEventListener("DOMContentLoaded", function() {
        var select = document.getElementById("attivitagestori-select");

        syncAttivitaGestori();

        if (select) {
            select.addEventListener("change", syncAttivitaGestori);
            select.addEventListener("click", syncAttivitaGestori);
        }
    });

})();