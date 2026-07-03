$(document).ready(function() {


	$('#save').on('click', function(e) {

	    if (!$("#tipologia").val()) {
	        alert("Selezionare una tipologia.");
	        $("#tipologia").focus();
	        return false;
	    }

	    if (!$("#n_data_req").val()) {
	        alert("Inserire la data richiesta utente.");
	        $("#n_data_req").focus();
	        return false;
	    }

	    if (!$("#n_descrizione").val().trim()) {
	        alert("Inserire la descrizione.");
	        $("#n_descrizione").focus();
	        return false;
	    }



	    $('#rilevazioni-comuni-form').submit();
	});


		
	$('.btn-del-row').on('click', function () {

	        var id = $(this).data('id');

	        if (!confirm('Confermi eliminazione richiesta?')) {

	            return;

	        }

	        $('#type').val('1');

	        $('input[name^="del_"]').prop('checked', false);

	        $('input[name^="mod_"]').prop('checked', false);

	        $('#del_' + id).prop('checked', true);

	        $('#rilevazioni-comuni-form').submit();

	    });

		$('.btn-mod-row').on('click', function () {

		    var id = $(this).data('id');

		    var dataEnd = $.trim($('[name="upd_' + id + '"]').val());

		    if (dataEnd.length === 0) {
		        alert('Inserire la data di espletamento richiesta.');
		        $('[name="upd_' + id + '"]').focus();
		        return false;
		    }

		    $('#type').val('2');

		    $('input[name^="del_"]').prop('checked', false);
		    $('input[name^="mod_"]').prop('checked', false);

		    $('#mod_' + id).prop('checked', true);

		    $('#rilevazioni-comuni-form').submit();

		});

	    $('#rilevazioni-comuni-form').on('submit', function (e) {

	        var type = $('#type').val();

	        /*

	         * For save only.

	         * Delete/update rows do not need tipologia.

	         */

	        if (type !== '1' && type !== '2') {

	            if ($("#tipologia").val() === "" || $("#tipologia").val() == null) {

	                e.preventDefault();

	                alert("Selezionare una tipologia.");

	                $("#tipologia").focus();

	                return false;

	            }

	        }

	    });
});