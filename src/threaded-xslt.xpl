	<p:declare-step name="threaded-xslt" type="ccproc:threaded-xslt" exclude-inline-prefixes="#all"
		pkg:import-uri="http://www.corbas.co.uk/xproc-tools/threaded-xslt"  xmlns:c="http://www.w3.org/ns/xproc-step"
		xmlns:pkg="http://expath.org/ns/pkg"  version="1.0" xmlns:data="http://www.corbas.co.uk/ns/transforms/data"
		xmlns:p="http://www.w3.org/ns/xproc" xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps">
		
		<p:documentation> This program and accompanying files are copyright 2008, 2009, 20011, 2012,
			2013 Corbas Consulting Ltd. This program is free software: you can redistribute it and/or
			modify it under the terms of the GNU General Public License as published by the Free
			Software Foundation, either version 3 of the License, or (at your option) any later version.
			This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
			without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
			See the GNU General Public License for more details. You should have received a copy of the
			GNU General Public License along with this program. If not, see
			http://www.gnu.org/licenses/. If your organisation or company are a customer or client of
			Corbas Consulting Ltd you may be able to use and/or distribute this software under a
			different license. If you are not aware of any such agreement and wish to agree other
			license terms you must contact Corbas Consulting Ltd by email at corbas@corbas.co.uk. </p:documentation>
		
		<p:documentation xmlns="http://wwww.w3.org/1999/xhtml">
			<table>
				<caption>Change Log</caption>
				<thead>
					<tr>
						<th>Revision No.</th>
						<th>Date</th>
						<th>Author</th>
						<th>Change</th>
					</tr>
				</thead>
				<tbody> 
					<tr> 
						<td>v0.1</td>
						<td>2011-08-22</td>
						<td>NG</td>
						<td>Initial Version</td>
					</tr>
					<tr>
						<td>v1.1</td>
						<td>2014-12-01</td>
						<td>NG</td>
						<td>
							<ul>
								<li>Removed support for secondary ports</li>
							</ul>
						</td>
						
					</tr>

					<tr>
						<td>v1.2</td>
						<td>2014-12-02</td>
						<td>NG</td>
						<td>
							<ul>
								<li>Refactored to a step from a library</li>
								<li>Added support for {http://www.corbas.co.uk/ns/transforms/data}:* attributes
								to be mapped into xsl params.</li>
								<li>Added secondary output port containing the intermediate results</li>
							</ul>
						</td>
						
					</tr>
					
				</tbody> 

			</table>
			
		</p:documentation>
		
		<p:documentation>
			<p xmlns="http:/wwww.w3.org/1999/xhtml">This step takes a sequence of transformation
				elements and executes them recursively applying the each stylesheet to the result of
				the previous stylesheet. The final result is the result of threading the input
				document through each of the stylesheets in turn.</p>
			<p xmlns="http:/wwww.w3.org/1999/xhtml">Secondary documents are ignored.</p>
		</p:documentation>
		
		<p:input port="source" sequence="false" primary="true">
			<p:documentation>
				<p xmlns="http://www.w3.org/1999/xhtml">The primary input for the step is the
					document to be transformed.</p>
			</p:documentation>
		</p:input>
		
		<p:input port="stylesheets" sequence="true">
			<p:documentation>
				<p xmlns="http://www.w3.org/1999/xhtml">The secondary input port for the step
					contains the sequence of xslt stylesheets (already loaded) to be executed.</p>
			</p:documentation>
		</p:input>
		
		<p:input port="parameters" kind="parameter" primary="true">
			<p:documentation>
				<p xmlns="http:/www.w3.org/1999/xhtml">The parameters to be passed to the p:xslt
					steps.</p>
			</p:documentation>
		</p:input>
		
		<p:output port="result" primary="true" sequence="true">
			<p:documentation>
				<p xmlns="http://www.w3.org/1999/xhtml">The output of the step is the transformed
					document.</p>
			</p:documentation>
			<p:pipe port="result" step="run-threaded-xslt"/>
		</p:output>
		
		<p:output port="intermediates" sequence="true">
			<p:documentation>
				<p xmlns="http://www.w3.org/1999/xhtml">The output of each step in the sequence.
					document. Each result is wrapped in a c:result element </p>
			</p:documentation>		
			<p:pipe port="intermediates-out" step="run-threaded-xslt"/>
		</p:output>
		
		<p:declare-step name="convert-meta" type="ccproc:convert-meta-to-param">
			<p:documentation  xmlns="http:/wwww.w3.org/1999/xhtml">
				<p>This step converts attributes in the http://www.corbas.co.uk/ns/transforms/data namesapce
				to parameters to be applied to the stylesheet. The attributes are not removed from the 
				stylesheet. The result of this a step is a <code>c:param-set</code> element.</p>
			</p:documentation>
			
			<p:input port="stylesheet" primary="true">
				<p:documentation  xmlns="http:/wwww.w3.org/1999/xhtml"><p>The stylesheet to be modified</p></p:documentation>
			</p:input>
			
			<p:output port="result" primary="true">
				<p:pipe port="result" step="build-parameters"/>
			</p:output>
			
			<p:xslt name="build-parameters">
				
				<!-- WE ARE PROCESSING A STYLESHEET! -->
				<p:input port="source">
					<p:pipe port="stylesheet" step="convert-meta"/>
				</p:input>
				<p:input port="stylesheet">
					<p:document href="build-params.xsl"/>
				</p:input>
				<p:input port="parameters">
					<p:empty/>
				</p:input>
				
			</p:xslt>
			
		</p:declare-step>
		
		<p:declare-step name="threaded-xslt-impl" type="ccproc:threaded-xslt-impl" exclude-inline-prefixes="#all">
			
			<p:documentation>
				<p xmlns="http:/wwww.w3.org/1999/xhtml">Internal implementation for ccproc:threaded-xslt. Handles the
				recursion and intermediate gathering without the need to expose the workings.</p>
			</p:documentation>
			
			<p:input port="source" sequence="false" primary="true">
				<p:documentation>
					<p xmlns="http://www.w3.org/1999/xhtml">Document to be transformed.</p>
				</p:documentation>
			</p:input>
			
			<p:input port="stylesheets" sequence="true">
				<p:documentation>
					<p xmlns="http://www.w3.org/1999/xhtml">Sequence of stylesheets</p>
				</p:documentation>
			</p:input>
			
			<p:input port="parameters" kind="parameter" primary="true">
				<p:documentation>
					<p xmlns="http:/www.w3.org/1999/xhtml">XSLT parameters</p>
				</p:documentation>
			</p:input>
			
			<p:input port="intermediates-in" sequence="true">
				<p:documentation xmlns="http://www.w3.org/1999/xhtml"><p>Document results so far.</p></p:documentation>
			</p:input>
			
			<p:output port="result" primary="true">
				<p:documentation>
					<p xmlns="http://www.w3.org/1999/xhtml">The output of the step is the transformed
						document.</p>
				</p:documentation>
			</p:output>
			
			<p:output port="intermediates-out" sequence="true">
				<p:documentation>
					<p xmlns="http://www.w3.org/1999/xhtml">The output of each step in the sequence.
						document.</p>
					<p:pipe port="result" step="build-intermediates"/>
				</p:documentation>			
			</p:output>
			
			
			<!-- Split of the first transformation from the sequence -->
			<p:split-sequence name="split-stylesheets" initial-only="true" test="position()=1">
				<p:input port="source">
					<p:pipe port="stylesheets" step="threaded-xslt-impl"/>
				</p:input>
			</p:split-sequence>
			
			<!-- How many of these are left? We actually only care to know  if there are *any* hence the limit. -->
			<p:count name="count-remaining-transformations" limit="1">
				<p:input port="source">
					<p:pipe port="not-matched" step="split-stylesheets"/>
				</p:input>
			</p:count>
			
			<!-- Ignore the result for now -->
			<p:sink/>
		
			<!-- find any metadata attributes on the stylesheet (these may be
				created by load-sequence-from-file) and convert them to a
				param-set to pass to Saxon -->
			<ccproc:convert-meta-to-param name="additional-params">
				<p:input port="stylesheet">
						<p:pipe port="matched" step="split-stylesheets"/>
				</p:input>
			</ccproc:convert-meta-to-param>
			
			
			<!-- run the stylesheet, merging parameters - params from the
				XProc run override those in the manifest -->
			<p:xslt name="run-single-xslt">
				<p:input port="stylesheet">
					<p:pipe port="matched" step="split-stylesheets"/>
				</p:input>
				<p:input port="source">
					<p:pipe port="source" step="threaded-xslt-impl"/>
				</p:input>
				<p:input port="parameters">
					<p:pipe port="result" step="additional-params"/>
					<p:pipe port="parameters" step="threaded-xslt-impl"/>
				</p:input>
			</p:xslt>
			
			<!-- copy the result to the intermediate outputs -->
			<p:identity name="build-intermediates">
				<p:input port="source">
					<p:pipe port="intermediates-in" step="threaded-xslt-impl"/>
					<p:pipe port="result" step="run-single-xslt"/>
				</p:input>
			</p:identity>
			
			<!-- If there are any remaining stylesheets recurse. The primary
    	input is the result of our XSLT and the remaining
    	sequence from split-transformations above will be the 
    	transformation sequence 
   		-->
			<p:choose name="determine-recursion">
				
				<p:xpath-context>
					<p:pipe port="result" step="count-remaining-transformations"/>
				</p:xpath-context>
				
				
				<!-- If we have any transformations remaining recurse -->
				<p:when test="number(c:result)>0">
					
					<ccproc:threaded-xslt-impl name="continue-recursion">
						
						<p:input port="stylesheets">
							<p:pipe port="not-matched" step="split-stylesheets"/>
						</p:input>
						
						<p:input port="source">
							<p:pipe port="result" step="run-single-xslt"/>
						</p:input>
						
						<p:input port="intermediates-in">
							<p:pipe port="result" step="build-intermediates"/>
						</p:input>
						
					</ccproc:threaded-xslt-impl>
					
				</p:when>
				
				<!-- Otherwise, pass the output of our transformation back as the result -->
				<p:otherwise>
					
					<p:identity name="terminate-recursion">
						<p:input port="source">
							<p:pipe port="result" step="run-single-xslt"/>
						</p:input>
					</p:identity>
					
				</p:otherwise>
				
			</p:choose>
			
		</p:declare-step>
		
		
		<!-- run it all -->
		<ccproc:threaded-xslt-impl name="run-threaded-xslt">
			
			<p:input port="source">
				<p:pipe port="source" step="threaded-xslt"/>
			</p:input>
			
			<p:input port="stylesheets">
				<p:pipe port="stylesheets" step="threaded-xslt"/>
			</p:input>

			<p:input port="parameters">
				<p:pipe port="parameters" step="threaded-xslt"/>
			</p:input>			
			
			<p:input port="intermediates-in">
				<p:empty/>
			</p:input>
			
		</ccproc:threaded-xslt-impl>
		
		
	</p:declare-step>
