$(document).ready(function() {
    // Apply restriction to all inputs with the 'number-comma-input' class
    $('.number-comma-input-200').on('input', function() {
        // Replace any character that is not a digit or a comma
        this.value = this.value.replace(/[^0-9,]/g, '');
    });

    $('.number-comma-input-200-readonly').on('keydown', function(e) {
        e.preventDefault(); // Prevent any key from being typed
    });



    var selectedValue = $('#attivitagestori-select').val();
    // Run this check on page load
    if (selectedValue !== 'default' && selectedValue !== null && selectedValue !== "") {
        $('#data-entry-div').removeClass('disabled');
        $('#data-entry-div :input').prop('disabled', false); // Enable inputs
        $('#id-attivitagestori').val(selectedValue);
    } else {
        $('#data-entry-div').addClass('disabled');
        $('#data-entry-div :input').prop('disabled', true); // Disable inputs
    }

    $('#attivitagestori-select').on('change', function() {
        $('#type').val('0');
        $('#manage-ricavi-form').submit();
    });



	$('#save').on('click', function () {

	    const form = document.getElementById("manage-ricavi-form");
	    const errorDiv = $('#validation-error');

	    errorDiv.hide().html('');
	    $('.field-error').removeClass('field-error');

	    const fields = [
	        { id: "new_1", msg: "Inserire la descrizione." },
	        { id: "new_2", msg: "Selezionare la tipologia di costo." },
	        { id: "new_3", msg: "Selezionare la categoria di costo." },
	        { id: "new_4", msg: "Selezionare la data dell'uscita." },
	        { id: "new_5", msg: "Inserire il valore dell'uscita." }
	    ];

	    for (const f of fields) {

	        const el = document.getElementById(f.id);

	        if (!el || !el.value || el.value.trim() === '') {

	            $(el).addClass('field-error');

	            errorDiv.html(
	                '<i class="bi bi-exclamation-triangle-fill"></i> ' +
	                f.msg
	            ).show();

	            $('html, body').animate({
	                scrollTop: errorDiv.offset().top - 100
	            }, 200);

	            el.focus();

	            return false;
	        }
	    }

	    const valore = $('#new_5').val().replace(',', '.');

	    if (isNaN(valore) || Number(valore) <= 0) {

	        $('#new_5').addClass('field-error');

	        errorDiv.html(
	            '<i class="bi bi-exclamation-triangle-fill"></i> ' +
	            'Inserire un valore numerico maggiore di zero.'
	        ).show();

	        $('#new_5').focus();

	        return false;
	    }

	    $('#type').val('2');
	    form.submit();
	});

    $('#del').on('click', function() {
        $('#type').val('1');
        $('#manage-ricavi-form').submit();  
    });


});

function showError(msg) {

    const div = document.getElementById("validation-error");

    div.innerHTML =

        '<i class="bi bi-exclamation-triangle-fill"></i> ' + msg;

    div.style.display = "block";

}

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