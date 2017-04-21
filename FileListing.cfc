/**
* A widget that renders a listing of the files in a folder.
*/
component extends="contentbox.models.ui.BaseWidget" singleton{

	FileListing function init(controller){
		// super init
		super.init(controller);

		// Widget Properties
		setName("FileListing");
		setVersion("1.1");
		setDescription("A widget that renders a listing of the files in a folder.");
		setForgeBoxSlug("cbwidget-filelisting");
		setAuthor("Computer Know How");
		setAuthorURL("http://www.compknowhow.com");
		setIcon("list");
		setCategory("Utilities");
		return this;
	}

	/**
	* Renders a file list
	* @folder.hint The folder (relative to the ContentBox content root) from which to list the files (meetings/minutes)
	* @filter.hint A file extension filter to apply (*.pdf)
	* @sort.hint The sort field (Name, Size, DateLastModified)
	* @order.hint The sort order of the files listed (ASC/DESC)
	* @class.hint Class(es) to apply to the listing table
	* @showIcons.hint Show file type icons (FontAwesome required)
	*/
	any function renderIt(string folder, string filter="*", string sort="Name", string order="ASC", string class="", boolean showIcons=false){
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

		if (directoryExists(mediaPathExpanded)) {
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
						if( listing.type[x] eq "File" ) {
							if(showIcons) {
								var fileExt = listLast(listing.name[x],".");

								switch(fileExt) {
									case "mp3": case "wav":
										iconString = "<i class='fa fa-file-audio-o'></i>";
										break;
									case "pdf":
										iconString = "<i class='fa fa-file-pdf-o'></i>";
										break;
									case "doc": case "docx":
										iconString = "<i class='fa fa-file-word-o'></i>";
										break;
									case "jpg": case "gif": case "png": case "bmp":
										iconString = "<i class='fa fa-file-image-o'></i>";
										break;
									case "ppt": case "pptx":
										iconString = "<i class='fa fa-file-powerpoint-o'></i>";
										break;
									default:
										iconString = "";
								}
							}
							// row
							writeOutput('
								<tr>
									<td class="cb-filelisting-name">');

							if(showIcons) {
								writeOutput('<a href="#mediaPath#/#listing.name[x]#" target="_blank">' & iconString & '</a> <a href="#mediaPath#/#listing.name[x]#" target="_blank">#listing.name[x]#</a>');
							} else {
								writeOutput('<a href="#mediaPath#/#listing.name[x]#" target="_blank">#listing.name[x]#</a>');
							}

							writeOutput('
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
										#dateFormat(listing.datelastmodified[x],'m/d/yyyy')#
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

		} else {
			return "The folder could not be found for listing";
		}

	}

}