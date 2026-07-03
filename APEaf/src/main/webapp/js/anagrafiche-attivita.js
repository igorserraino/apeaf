

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

					    const denominazione = document.getElementById("nome-attivita");

					    denominazione.classList.remove("field-error");
					    denominazione.setCustomValidity("");

					    if (!denominazione.value.trim()) {

					        denominazione.classList.add("field-error");
					        denominazione.setCustomValidity("Compilare il campo.");
					        denominazione.reportValidity();
					        denominazione.focus();

					        return false;
					    }

					    $('#op').val("1");
					    $('#anagrafiche-form').submit();

					});
			
			
			
			var attivita_esistenti = $('#attivita_esistenti');
					attivita_esistenti.change(function() {
						$('#op').val("0");
						$('#anagrafiche-form').submit();
						});
						
						

						
});

