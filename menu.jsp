<%@ page import="cn.myapps.constans.Web"%>
<%@ page import="cn.myapps.core.user.action.WebUser"%>
<%@ page import="cn.myapps.core.department.ejb.DepartmentVO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="net.sf.json.JSONArray"%>
<%@ taglib uri="/struts-tags" prefix="s"%>
<%@ taglib uri="myapps" prefix="o"%>

<%!
	String Driver = "com.mysql.jdbc.Driver";
	String dbUrl = "jdbc:mysql://127.0.0.1:3307/pm";
	String dbUser = "root";
	String dbPassword = "123456";
	public String resultToJson(ResultSet rs) throws Exception {
		ResultSetMetaData md = rs.getMetaData();
		int columnCount = md.getColumnCount();
		ArrayList list = new ArrayList();
		Map rowData;
		while(rs.next()){
			rowData = new HashMap(columnCount);
			for(int i = 1; i <= columnCount; i++){			
				rowData.put(md.getColumnLabel(i), rs.getObject(i));
			}
			list.add(rowData);	    	
		}
		JSONArray json = JSONArray.fromObject(list);
		return json.toString();
	}
%>

<%
	String tasks = "[]";
	String dalay = "[]";
	try{
		Class.forName(Driver);
		Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
		Statement stmt = conn.createStatement();
		String sql = "SELECT WBS_ as wbs, NAME_ as name,PERCENTCOMPLETE_ as percent,START_ as start,FINISH_ as finish,BASEFINISH_ as basefinish from plus_task";
		ResultSet rs = stmt.executeQuery(sql);
		tasks = resultToJson(rs);
        rs.close();
        
        sql = "SELECT item_滞后天数 as day FROM tlk_indicators_set";
        rs = stmt.executeQuery(sql);
        dalay = resultToJson(rs);
        rs.close();

		stmt.close();
		conn.close();
	}catch(ClassNotFoundException e){
		e.printStackTrace();
	}catch(SQLException e){
		e.printStackTrace();
	}catch(Exception e){
		e.printStackTrace();
	}
%>

<o:MultiLanguage value="FRONTMULTILANGUAGETAG">
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1">
	<style type="text/css">
	    body{background: url(http://192.168.0.8:8080/Z0163A/portal/report/images/background2.jpg);}
	    #container{height: 100%;background-repeat: no-repeat;}
		#container {margin-left: 4em;margin-top: 3em;}
		#cover,.table {display: none;}
		#cover,#close {position: absolute;}
		.table > table td,.item {text-align: center;}
		#cover{width: 100%;left: 0;top: 0;background-color: transform;z-index: 9;}
		.table {position: fixed;background-color: #fff;border:2px solid #4470a7;z-index: 10;}
		.table > table {width: 70%;height: 70%;margin: auto;margin-top: 11%;border-collapse: collapse;border: solid 1px #3dbde6;}
		.table > table td {border: 1px solid #333;width: 5%;border: solid 1px #3dbde6;}
		.row {display: flex;}
		.right{width: 100%;display: flex;flex-wrap: wrap;}
		.item {width: 16em;height: 3em;margin-left: .6em;border-radius: 10px;color: #fff;font-size: 1.2em;font-weight: 800;line-height: 3em;font-family: "华文仿宋";overflow: hidden;text-overflow:ellipsis;white-space: nowrap;margin-bottom: 1.5em;box-shadow: 3px 3px 7px #42424296}
		.first {background-color: #ccc;margin-right: 2em;}
		#close{width: 3em;height: 3em;background: url(http://192.168.0.8:8080/Z0163A/portal/report/images/close.jpg);background-size: 80% 80%;background-repeat: no-repeat;right: 0.1em;top: 0.6em;}		
	</style>

</head>
<body>
	<div id="container">
		<div class="menu">					
			<div id="cover">
			</div>
			<div class="table" id="table">
				<table id="realtable">
					<tbody>									
						<tr>
							<td>任务名称</td>
							<td><span id="name"></span></td>
							<td>完成情况</td>
							<td><span id="percent"></span></td>
						</tr>
						<tr>
							<td>开始时间</td>
							<td><span id="start"></span></td>
							<td>完成时间</td>
							<td><span id="finish"></span></td>
						</tr>
						<tr id="change">
						</tr>
					</tbody>
				</table>
				<div id="close">
				</div>
			</div>					    
	    </div>
	</div>
	<script src="./resource/script/jquery-1.7.1.min.js"></script>
	<script type="text/javascript">
		var showTable = document.querySelector("#table");
		var table = document.querySelector("#realtable");
		var close = document.querySelector("#close");
        var cover = document.querySelector("#cover");

        //弹出界面位于屏幕中间
        const wd = window.top.document.documentElement.clientWidth;
        const ht = window.top.document.documentElement.clientHeight;
        showTable.style.left = (wd/7)+'px';
        showTable.style.top = (ht/15)+'px';
        showTable.style.width = (wd/1.5)+'px';
        showTable.style.height = (ht/1.5)+'px';
        if(document.documentElement.scrollHeight <900){
        	cover.style.height = 2*document.documentElement.scrollHeight + 'px';
        }else{
        	cover.style.height = 1.1*document.documentElement.scrollHeight + 'px';
        }

        //获取滞后天数N	    
        const dalay = JSON.parse('<%=dalay%>');
        const dalay_days = dalay[0].day*1;
		const tasks = JSON.parse('<%=tasks%>');
		const first = [];
		const second = [];
		const third = [];
		const im_task = [];
		const menu = document.querySelector('#container .menu');
		const nameSpan = document.querySelector('#name');
		const percentSpan = document.querySelector('#percent');
		const startSpan = document.querySelector('#start');
		const finishSpan = document.querySelector('#finish');
		const noteUl = document.querySelector('#note');

		for ( const i in tasks ) {
			const task = tasks[i];
			if ( task.wbs.indexOf('.') == -1 ) {			
					task.children = [];//子任务
						
					first.push(task);				    			
			} else if( task.wbs.indexOf('.',2) != 3 ){				
				second.push(task);
			} else{
                third.push(task);        
			}
		}

		for ( const i in second ) {
			const child = second[i];
			child.grandchildren = [];
			const parentIndex = child.wbs.split('.')[0];
			first[parentIndex - 1].children.push(child);//子任务插入
		}
               
        for ( const i in third ){
        	const child = third[i];
        	const parentIndex = child.wbs.split('.')[0];
        	const sonIndex = child.wbs.split('.')[1];
        	first[parentIndex -1].children[sonIndex -1].grandchildren.push(child);//二级子任务插入
        }

        console.log(first);
		const divTemp = document.createElement('div');
		const divLeft = document.createElement('div');

		for ( const i in first ) {
			const task = first[i];
			const children = task.children;
			 
			const div = divTemp.cloneNode();
			div.className = 'row';
			div.innerHTML = '\
				<div class="first item" style="background:'+colorDecision(task.percent)+'">\
					'+ task.name +'\
				</div>\
			';
			const div2 = divLeft.cloneNode();
			div2.className = 'right';
			
			if ( children && children.length ) {
				for ( const j in children ) {	
					const sonTask = children[j];
					const grandchildren = task.children[j].grandchildren;
					const sonDiv = divTemp.cloneNode();
					//判断滞后天数
					const son_finish = sonTask.finish.time; 					
					const son_basefinish = sonTask.basefinish.time;
					var day = (son_finish - son_basefinish)/86400000 + 1;
											
					sonDiv.className = 'second item';
					sonDiv.style.background = colorDecision(sonTask.percent,day,dalay_days);
					sonDiv.textContent = sonTask.name;
					sonDiv.setAttribute('data-wbs', sonTask.wbs);									
					sonDiv.addEventListener('click', function() {
                        showTable.style.display = 'block';
                        cover.style.display = "block";
                        if( grandchildren && grandchildren.length ){  
                            const hh = grandchildren.length;                     		
			                for( const h in grandchildren ){
			                	var grandsonTask = grandchildren[h];		                			                	
			                	var annexRow =  table.insertRow(+h+2);			                				                	
			                	const cell1 = annexRow.insertCell(0);
							    const cell2 = annexRow.insertCell(1);
							    cell1.innerHTML = "附件";					    							    
							    cell2.innerHTML = grandsonTask.name;			                 	
			                    }			                   
			                for( const h in grandchildren ){
			                	var grandsonTask = grandchildren[h];
			                	const noteRow = table.insertRow(+h+hh+2);			                	
			                	const cell1 = noteRow.insertCell(0);
							    const cell2 = noteRow.insertCell(1);
							    cell1.innerHTML = "滞后原因";
							    cell2.innerHTML = grandsonTask.name;
			                }
			                for( const h in grandchildren ){
			                	var grandsonTask = grandchildren[h];
			                	const messureRow = table.insertRow(+h+2*hh+2);
			                	const cell1 = messureRow.insertCell(0);
							    const cell2 = messureRow.insertCell(1);
							    cell1.innerHTML = "整改措施";
							    cell2.innerHTML = grandsonTask.name;
			                }
			                $.ajax({
			                	url: './resource/api/getTaskData2.jsp',
			                	dataType: 'json',
								type: 'POST',
								data: { 
									wbs: sonTask.wbs.toString()
								},
                                success:function(info){
                                	// console.log({info});                                  
									for( const k in info ){
										var { wbs, note, measures, handle, annex } = info[k];
										var grand_wbs = [];
                                        var grand_note = [];
										var grand_measures = [];
										var grand_handle = [];
										var grand_annex = [];								
										grand_wbs[k] = info[k].wbs;
										grand_note[k] = info[k].note;
										grand_measures[k] = info[k].measures;
										grand_handle[k] = info[k].handle;
										grand_annex[k] = info[k].annex;
									};
									for( const h in grandchildren ){
										var grandsonTask = grandchildren[h];
										const hh = grandchildren.length;
                                        if( info.length ){
                                        	for( const k in grand_wbs ){
												if( grandsonTask.wbs == grand_wbs[k] ){	
												    const cell1 = table.rows[+h+2].insertCell(2);	
												    var gra_annexs = JSON.parse(grand_annex[k]);	
												    for(const l in gra_annexs){
                                                        cell1.innerHTML += grand_handle[k] + ':<a href="http://192.168.0.8:8080/Z0163A/' + gra_annexs[l].path + '">' + gra_annexs[l].name + "</a><br>";
												    }												    							   											    
												    cell1.setAttribute("colspan",2);
												    const cell2 = table.rows[+h+hh+2].insertCell(2);
												    cell2.innerHTML = grand_handle[k] + ":" + grand_note[k];;
												    cell2.setAttribute("colspan",2);
												    const cell3 = table.rows[+h+2*hh+2].insertCell(2);	
												    cell3.innerHTML = grand_handle[k] + ":" + grand_measures[k];		
												    cell3.setAttribute("colspan",2);						
											    }
											    else{
											    	const cell1 = table.rows[+h+2].insertCell(2);											    
												    cell1.innerHTML = "";
												    cell1.setAttribute("colspan",2);
												    const cell2 = table.rows[+h+hh+2].insertCell(2);
												    cell2.innerHTML = "";
												    cell2.setAttribute("colspan",2);
												    const cell3 = table.rows[+h+2*hh+2].insertCell(2);	
												    cell3.innerHTML = "";	
												    cell3.setAttribute("colspan",2);	
											    }
                                            }										
										}else{
											const cell1 = table.rows[+h+2].insertCell(2);											    
										    cell1.innerHTML = "";
										    cell1.setAttribute("colspan",2);
										    const cell2 = table.rows[+h+hh+2].insertCell(2);
										    cell2.innerHTML = "";
										    cell2.setAttribute("colspan",2);
										    const cell3 = table.rows[+h+2*hh+2].insertCell(2);	
										    cell3.innerHTML = "";	
										    cell3.setAttribute("colspan",2);
										}																			
									}
                                },
                                error: function(...error) {
										console.error(...error);
								}
			                });
			                $(function() {
					           $("#realtable").rowspan(0);
					        });
					    }else{
                                const annexRow = table.insertRow(2);
                                const noteRow = table.insertRow(3);
                                const messuresRow = table.insertRow(4);
                                var annex_cell1 = annexRow.insertCell(0);
							    var annex_cell2 = annexRow.insertCell(1);
							    var annex_cell3 = annexRow.insertCell(2);
							    annex_cell3.setAttribute('colspan',2);
							    var note_cell1 = noteRow.insertCell(0);
							    var note_cell2 = noteRow.insertCell(1);
							    var note_cell3 = noteRow.insertCell(2);
							    note_cell3.setAttribute('colspan',2);	
							    var messures_cell1 = messuresRow.insertCell(0);
							    var messures_cell2 = messuresRow.insertCell(1);
							    var messures_cell3 = messuresRow.insertCell(2);
							    messures_cell3.setAttribute('colspan',2);				    
							    annex_cell1.innerHTML = "附件";
							    note_cell1.innerHTML = "滞后原因";
							    messures_cell1.innerHTML = "整改措施";
							    $.ajax({
									url: './resource/api/getTaskData.jsp',
									dataType: 'json',
									type: 'POST',
									data: { 
										wbs: sonTask.wbs.toString()
									},
									success: function(info) {								
										// console.log({info});
										// 显示数据																				
										let noteHtml = measuresHtml = annexHtml = '';
										/**
										 * note --> 滞后原因
										 * measures --> 措施
										 * annex --> 附件
										 * handle --> 时间
										 */
									for ( const k in info ) {
									const { note, measures, handle, annex } = info[k];
									var son_annex = JSON.parse(annex);
									annexHtml += '<li>'+ handle + '，' + '<a href="http://192.168.0.8:8080/Z0163A/'+ son_annex[k].path +'">' + son_annex[k].name + '</a></li>';
									noteHtml += '<li>'+ handle +'，'+ note +'</li>';
		                            measuresHtml += '<li>'+ handle +'，'+ measures +'</li>';
									}
									annex_cell3.innerHTML = annexHtml;
									note_cell3.innerHTML = noteHtml;
									messures_cell3.innerHTML = measuresHtml;
									},
									error: function(...error) {
										console.error(...error);
									}
						        });
					        }

						nameSpan.textContent = sonTask.name;
						percentSpan.textContent = sonTask.percent;
						startSpan.textContent = dateFormat(sonTask.start);
						finishSpan.textContent = dateFormat(sonTask.finish);						 
					});
					//关闭table
                    close.addEventListener('click',function(){
                        showTable.style.display = "none";
                    	for( var len = 0;len < table.rows.length-2;len++ ){
                                table.deleteRow(len+2);
			            }
                    })                   
					div2.appendChild(sonDiv);
					div.appendChild(div2);					                
				}                			
			menu.appendChild(div);                       			
		}
	}

    //左右布局
    // var first = getEle

	close.addEventListener('click',function(){
		cover.style.display = 'none';
	})

    //日期格式转换
	function dateFormat(obj) {
		return (obj.year+1900) +'年'+ (+obj.month+1) +'月'+ obj.date +'日';
	}

    //颜色显示
    function colorDecision(percent,day,dalay_days){
        if(percent == 100){
        	return "#05b596";
        }else if(percent >0 && percent < 100){
        	return "#efc244";
        }else if(percent == 0){
        	if(day>dalay_days){
        		return "#c51c1c";
        	}else{return "#939096";}        	
        }   	
    };
    
    //封装表格相同行合并的JQuery插件
    jQuery.fn.rowspan = function(colIdx) {
	    return this.each(function(){
	        var that;
	            $('tr', this).each(function(row) {
	                $('td:eq('+colIdx+')', this).filter(':visible').each(function(col) {
	                    if (that!=null && $(this).html() == $(that).html()) {
	                    rowspan = $(that).attr("rowSpan");
	                    if (rowspan == undefined) {
	                        $(that).attr("rowSpan",1);
	                        rowspan = $(that).attr("rowSpan"); 
	                    }
	                    rowspan = Number(rowspan)+1;
	                    $(that).attr("rowSpan",rowspan);
	                    $(this).hide();
	                } else {
	                    that = this;
	                }
	            });
	        });
	    });
    }

	</script>	
</body>
</html>
</o:MultiLanguage>