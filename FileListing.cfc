/**
* A widget that renders a listing of the files in a folder.
*/
component extends="contentbox.model.ui.BaseWidget" singleton{

	FileListing function init(controller){
		// super init
		super.init(controller);

		// Widget Properties
		setPluginName("FileListing");
		setPluginVersion("1.0");
		setPluginDescription("A widget that renders a listing of the files in a folder.");
		setForgeBoxSlug("cbwidget-filelisting");
		setPluginAuthor("Computer Know How");
		setPluginAuthorURL("http://www.compknowhow.com");
		setIcon( "list.png" );
		setCategory( "Utilities" );
		return this;
	}

	/**
	* Renders a file list
	* @folder.hint The folder (relative to the ContentBox content root) from which to list the files (meetings/minutes)
	* @filter.hint A file extension filter to apply (*.pdf)
	* @sort.hint The sort field (Name, Size, DateLastModified)
	* @order.hint The sort order of the files listed (ASC/DESC)
	* @class.hint Class(es) to apply to the listing table
	*/
	any function renderIt(string folder,string filter="*",string sort="Name",string order="ASC",string class=""){
		var event = getRequestContext();
		var cbSettings = event.getValue(name="cbSettings",private=true);
		var sortOrder = arguments.sort & " " & arguments.order;
		var mediaRoot = expandPath(cbSettings.cb_media_directoryRoot);
		var mediaPath = "modules" & cbSettings.cb_media_directoryRoot & "/" & arguments.folder;
		var mediaPathExpanded = expandPath(mediaPath);
		//security check - can't be higher then the media root
		if(!findNoCase(mediaRoot, mediaPathExpanded)){
			return "This widget is restricted to the ContentBox media root.  All file lists must be contained within that directory.";
		}
		var listing = directoryList(mediaPathExpanded,false,"query",arguments.filter,sortOrder);

		// generate file listing
		saveContent variable="rString"{
			// container (start)
			writeOutput('<div class="cb-filelisting">');

			if( listing.recordcount gt 0 ){
				writeOutput('
					<table class="#class#">
						<thead>
							<tr>
								<th class="cb-filelisting-name">
									Name
								</th>
								<th class="cb-filelisting-size">
									Size
								</th>
								<th class="cb-filelisting-modified">
									Modified
								</th>
							</tr>
						</thead>
						<tbody>
				');

				for (var x=1; x lte listing.recordcount; x++) {
					if( listing.type eq "File" ) {
						// row
						writeOutput('
							<tr>
								<td class="cb-filelisting-name">
									<a href="#mediaPath#/#listing.name[x]#" target="_blank">#listing.name[x]#</a>
								</td>
								<td class="cb-filelisting-size">
						');
						if( listing.size[x] GT 1000 ) {
							writeOutput('#numberFormat(listing.size[x]/1000)# KB');
						} else {
							writeOutput('#decimalFormat(listing.size[x]/1000)# KB');
						}
						writeOutput('
								</td>
								<td class="cb-filelisting-modified">
									#listing.datelastmodified[x]#
								</td>
							</tr>
						');
					}
				}

				writeOutput('
						</tbody>
					</table>
				');
			} else {
				writeOutput('
					<div class="no-records">
						No files to display
					</div>
				');
			}

			// container (end)
			writeOutput('</div>');
		}

		return rString;

		// return "The folder could not be found for listing";
	}

}