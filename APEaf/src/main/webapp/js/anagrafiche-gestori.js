
document.addEventListener("DOMContentLoaded", function() {

    const tipologia = document.getElementById("tipologia");

    const modalita  = document.getElementById("modalita");

    const anagrafica = document.getElementById("anagrafica-div");

    function checkSelections() {

        const tipologiaSelected =

            tipologia.value && tipologia.value !== "0";

        const modalitaSelected =

            modalita.value && modalita.value !== "0";

        anagrafica.style.display =

            (tipologiaSelected && modalitaSelected)

                ? "block"

                : "none";

    }

    tipologia.addEventListener("change", checkSelections);

    modalita.addEventListener("change", checkSelections);

    checkSelections();

});


$(document).ready(function() {
	


	var prorogarow = $('#proroga-row');
	var prorogayes = $('#proroga-yes');
	var prorogano = $('#proroga-no');

		prorogayes.click(function() {
			
			if ($(this).is(':checked')) {
				prorogano.prop('checked', false);
				prorogarow.css("visibility", "visible");
			} else {
				prorogano.prop('checked', true);
				prorogarow.css("visibility", "hidden");
			}
		});
		
		prorogano.click(function() {

					if ($(this).is(':checked')) {
						prorogayes.prop('checked', false);
						prorogarow.css("visibility", "hidden");
					} else {
						prorogayes.prop('checked', true);
						prorogarow.css("visibility", "visible");
					}
				});
				
				
		var tipologia = $('#tipologia');	
		var modalita = $('#modalita');	
		var modalitadatatable = $('#modalita-data-table');
		var modalitadatatable2 = $('#modalita-data-table2');
		
		modalita.change(function() {
		           var selectedValue = $(this).val();
		           if (selectedValue === "3") {
						modalitadatatable.css("visibility", "visible");
						modalitadatatable2.css("visibility", "hidden");
		           } else {
					if (selectedValue === "2") {
							modalitadatatable2.css("visibility", "visible");
							modalitadatatable.css("visibility", "visible");
							} else {
								modalitadatatable.css("visibility", "hidden");
								modalitadatatable2.css("visibility", "hidden");
							 }
		           }
		       });
			   
			   
		var save = $('#save');
		save.click(function(e) {

		    e.preventDefault();

		    const denominazione = document.getElementById("denominazione");

		    denominazione.classList.remove("field-error");
		    denominazione.setCustomValidity("");

		    if (!denominazione.value.trim()) {

		        denominazione.classList.add("field-error");
		        denominazione.setCustomValidity("Compilare la denominazione della società affidataria");
		        denominazione.reportValidity();
		        denominazione.focus();

		        return false;
		    }

		    $('#op').val("1");
		    $('#anagrafiche-form').submit();

		});
			

			
			
			
			var gestori_esistenti = $('#gestori_esistenti');
					gestori_esistenti.change(function() {
						$('#op').val("0");
						$('#anagrafiche-form').submit();
						});
						
						

						
});

document.addEventListener("DOMContentLoaded", function () {

    const container = document.getElementById("anagrafica-div");

    if (!container) return;

    container.querySelectorAll(

        'input[type="text"], input[type="date"], input[type="number"], select'

    ).forEach(function(el) {

        if (el.id !== "start_pr" && el.id !== "end_pr") {

            el.required = true;

        }

    });

});

document.addEventListener("DOMContentLoaded", function () {

    const yesRadio = document.getElementById("proroga-yes");

    const startPr  = document.getElementById("start_pr");

    const endPr    = document.getElementById("end_pr");

    function updateProrogaRequired() {

        const required = yesRadio && yesRadio.checked;

        if (startPr) startPr.required = required;

        if (endPr) endPr.required = required;

    }

    if (yesRadio) {

        yesRadio.addEventListener("change", updateProrogaRequired);

    }

    document.querySelectorAll('input[name="<%= Utils.FIELD_PREFIX %><%= n-3 %>"]')

        .forEach(r => r.addEventListener("change", updateProrogaRequired));

    updateProrogaRequired();

});

