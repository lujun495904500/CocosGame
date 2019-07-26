/**
 *	@file	TMXObject.h
 *	@date	2018/02/03
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	TMX 对象
 */

#ifndef __TMXOBJECT_20180203230753_H
#define __TMXOBJECT_20180203230753_H

#include "base/CCRef.h"
#include "base/CCValue.h"
#include "math/CCGeometry.h"
#include "external/rapidxml/rapidxml.hpp"

USING_NS_CC;
using namespace rapidxml;

namespace L {

/**
*	@brief TMX对象
*/
class CC_DLL TMXObject : public Ref {
public:
	TMXObject();
	virtual ~TMXObject();

	// 解析对象
	void parseObject(xml_node<> *node);

	int getId() const { return _id; }
	const std::string& getType() const { return _type; }
	const std::string& getName() const { return _name; }
	const ValueMap& getProperties() const { return _properties; }
	const Value& getProperty(const std::string &name) { return _properties[name]; }
	Rect getBounds() const { return Rect(_x,_y,_width,_height); }
	bool isVisible() const { return _visible; }
	void setVisible(bool visible) { _visible = visible; }

protected:
	
	int				_id;
	std::string		_type;
	std::string		_name;
	int				_x;
	int				_y;
	int				_width;
	int				_height;
	bool			_visible;

	ValueMap		_properties;	// 属性
};

}

#endif //!__TMXOBJECT_20180203230753_H
